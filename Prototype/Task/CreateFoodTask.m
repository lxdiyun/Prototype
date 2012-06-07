//
//  CreateFoodTask.m
//  Prototype
//
//  Created by Adrian Lee on 6/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CreateFoodTask.h"

#import "FoodManager.h"
#import "EventPage.h"
#import "AppDelegate.h"
#import "ImageManager.h"
#import "UIImage+Scale.h"
#import "EventManager.h"
#import "Util.h"
#import "PlaceManager.h"

const static CGFloat MAX_FOOD_PIC_RESOLUTION = 960.0;

typedef enum PARAMS_STATUS_ENUM
{
	PARAM_EMPTY = 0x0,
	PARAM_PIC_READY = 0x1 << 0,
	PARAM_PLACE_READY = 0x1 << 1,
	PARAM_ETC_READY = 0x1 << 2,
	PARAM_ALL_READY = (0x1 << 3) - 1
} PARAMS_STATUS;

@interface CreateFoodTask ()
{
	PARAMS_STATUS _paramStatus;
	NSMutableDictionary *_params;
	UIImage *_seletedImage;
}

@property (strong, nonatomic) NSMutableDictionary *params;
@property (assign, nonatomic) PARAMS_STATUS paramStatus;
@property (strong, nonatomic) UIImage *seletedImage;

@end

@implementation CreateFoodTask

@synthesize params = _params;
@synthesize paramStatus = _paramStatus;
@synthesize seletedImage = _seletedImage;

#pragma mark - life circle

- (id) init
{
	self =[super init];
	
	if (nil != self)
	{
		if (nil == self.params)
		{
			NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
			
			self.params = params;
			
			[params release];
		}
		
		[self.params removeAllObjects];
		
		self.paramStatus = PARAM_EMPTY;
		self.seletedImage = nil;
	}
	
	return self;
}

- (void) dealloc
{
	self.params = nil;
	self.seletedImage = nil;
	[super dealloc];
}

#pragma mark - task

- (BOOL) isAllConditionReady
{
	if ((PARAM_PIC_READY != self.paramStatus) && (nil != self.seletedImage))
	{
		NSMutableDictionary *taskEvent = [self.params mutableCopy];
		
		[taskEvent setValue:self.seletedImage forKey:@"pic"];
		[EventManager addTaskEvent:taskEvent with:self];
		[EventPage requestUpdate];
		
		[taskEvent release];
	}

	return self.paramStatus == PARAM_ALL_READY;
}

- (void) execute
{
	[FoodManager createFood:self.params withHandler:@selector(foodCreated:) andTarget:self];
	self.seletedImage = nil;
}

#pragma mark - handler and interface

- (void) foodCreated:(id)result
{
	NSNumber *foodID = [[result valueForKey:@"result"] valueForKey:@"id"];
	
	if (nil != foodID)
	{
		[EventPage cleanAndRefresh];
		[EventManager removeTaskEvent:self];
		
		[self confirm];
	}
	else 
	{
		[self cancel];
	}
}

- (void) placeReady:(id)result
{
	NSNumber *placeID = [[result valueForKey:@"result"] valueForKey:@"id"];
	
	if (nil != placeID)
	{
		[self.params setValue:placeID forKey:@"place"];
		
		self.paramStatus |= PARAM_PLACE_READY;
		
		[self checkCondition];
	}
	else 
	{
		[self cancel];
	}
}

- (NSInteger) picSelected:(UIImage *)pic
{
	if (nil != pic)
	{
		UIImage *resizedImage = [pic reduceToResolution:MAX_FOOD_PIC_RESOLUTION];
		self.seletedImage = resizedImage;
		
		return [ImageManager createImage:resizedImage withHandler:@selector(picReady:) andTarget:self];
	}
	else
	{
		return 0;
	}
}

- (void) picReady:(id)result
{
	NSDictionary *pic = [result valueForKey:@"result"];
	NSNumber *picID = [pic valueForKey:@"id"];
	
	if (nil != picID)
	{
		[self.params setValue:picID forKey:@"pic"];
		
		[ImageManager saveImageCache:self.seletedImage with:pic];
		
		self.paramStatus |= PARAM_PIC_READY;

		[self checkCondition];
	}
	else 
	{
		[self cancel];
	}
}

- (void) etcReady:(NSDictionary *)etcParams
{
	[self.params addEntriesFromDictionary:etcParams];
	
	self.paramStatus |= PARAM_ETC_READY;
	
	[AppDelegate showPage:EVENT_PAGE];
	
	[self checkCondition];
}
	    
- (void) placeSelected:(NSDictionary *)placeObject
{
	[PlaceManager createPlace:placeObject 
		      withHandler:@selector(placeReady:) 
			andTarget:self];
}


@end
