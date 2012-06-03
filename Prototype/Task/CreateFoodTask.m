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

const static CGFloat MAX_FOOD_PIC_RESOLUTION = 960.0;

typedef enum PARAMS_STATUS_ENUM
{
	PARAM_EMPTY = 0x0,
	PARAM_PIC_READY = 0x1 << 0,
	PARAM_ETC_READY = 0x1 << 1,
	PARAM_ALL_READY = (0x1 << 2) - 1
} PARAMS_STATUS;

@interface CreateFoodTask ()
{
	PARAMS_STATUS _paramStatus;
	NSMutableDictionary *_params;
}

@property (strong, nonatomic) NSMutableDictionary *params;
@property (assign, nonatomic) PARAMS_STATUS paramStatus;

@end

@implementation CreateFoodTask

@synthesize params = _params;
@synthesize paramStatus = _paramStatus;

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
	}
	
	return self;
}

- (void) dealloc
{
	self.params = nil;
	[super dealloc];
}

#pragma mark - task

- (BOOL) isAllConditionReady
{
	return self.paramStatus == PARAM_ALL_READY;
}

- (void) execute
{
	[FoodManager createFood:self.params withHandler:@selector(foodCreated:) andTarget:self];
}

#pragma mark - handler and interface

- (void) foodCreated:(id)result
{
	NSNumber *foodID = [[result valueForKey:@"result"] valueForKey:@"id"];
	
	if (nil != foodID)
	{
		[EventPage requestUpdate];
		[AppDelegate showPage:EVENT_PAGE];
		
		[self confirm];
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
		
		return [ImageManager createImage:resizedImage withHandler:@selector(picCreated:) andTarget:self];
	}
	else
	{
		return 0;
	}
}

- (void) picCreated:(id)result
{
	NSNumber *picID = [[result valueForKey:@"result"] valueForKey:@"id"];
	
	if (nil != picID)
	{
		[self.params setValue:picID forKey:@"pic"];
		
		self.paramStatus |= PARAM_PIC_READY;

		[self checkCondition];
	}
	else 
	{
		[self cancel];
	}
}

- (void) etcCreated:(NSDictionary *)etcParams
{
	[self.params addEntriesFromDictionary:etcParams];
	
	self.paramStatus |= PARAM_ETC_READY;
	
	[self checkCondition];
}


@end
