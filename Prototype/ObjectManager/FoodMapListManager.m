//
//  FoodMapListManager.m
//  Prototype
//
//  Created by Adrian Lee on 3/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FoodMapListManager.h"

#import "Util.h"
#import "LoginManager.h"
#import "PlaceManager.h"

@interface FoodMapListManager ()
{
	
}

@end

@implementation FoodMapListManager

#pragma mark - singelton
DEFINE_SINGLETON(FoodMapListManager);

#pragma mark - class interface

+ (void) updateFoodMap:(NSDictionary *)foodMap 
	   withHandler:(SEL)handler 
	     andTarget:target;
{
	@autoreleasepool 
	{
		NSString *loginUserID = [GET_USER_ID() stringValue];
		
		[self requestUpdateWithObject:foodMap 
				       inList:loginUserID 
				  withHandler:handler 
				    andTarget:target];
	}
}

#pragma mark - life circle

- (id) init
{
	self = [super init];
	
	if (nil !=self) 
	{
		@autoreleasepool 
		{
			self.getMethodString = @"foodmap.get_list";
			self.createMethodString = @"foodmap.create";
			self.updateMethodString = @"foodmap.update";
		}
	}
	
	return self;
}

#pragma mark - overwrite super class method
#pragma mark - overwrite super classs get method

- (void) configGetMethodParams:(NSMutableDictionary *)params forList:(NSString *)listID
{
	@autoreleasepool 
	{
		// map list against special user
		[params setValue:[NSNumber numberWithInt:[listID intValue]] forKey:@"user"];
	}
}

- (void) getMethodHandler:(id)result withListID:(NSString *)listID forward:(BOOL)forward
{
	[super getMethodHandler:result withListID:listID forward:forward];
	
	NSDictionary *messageDict = [(NSDictionary*)result retain];
	
	for (NSDictionary *object in [messageDict objectForKey:@"result"]) 
	{
		[PlaceManager requestObjectWithNumberIDArray:[object valueForKey:@"places"]];
	}
	
	[messageDict release];
}

@end
