//
//  FoodManager.m
//  Prototype
//
//  Created by Adrian Lee on 1/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FoodManager.h"

#import "ProfileMananger.h"
#import "ImageManager.h"
#import "PlaceManager.h"
#import "EventManager.h"
#import "UserFoodHistoryManager.h"
#import "Util.h"

@implementation FoodManager

#pragma mark - singleton

DEFINE_SINGLETON(FoodManager);

#pragma mark - class interface
+ (void) createFood:(NSDictionary *)params 
	withHandler:(SEL)handler 
	  andTarget:target
{
	[[self getInstnace] setCreateParams:params];
	
	[self createObjectWithHandler:handler andTarget:target];
}

#pragma mark - overwrite super class method

#pragma mark - get method handler overwrite

- (void) handlerForSingleResult:(id)result
{
	[super handlerForSingleResult:result];
	
	NSDictionary *object = [result valueForKey:@"result"];
	
	NSNumber *picID = [object valueForKey:@"pic"];

	if (CHECK_NUMBER(picID))
	{
		if (nil == [ImageManager getObjectWithNumberID:picID])
		{
			[ImageManager requestObjectWithNumberID:picID 
						     andHandler:nil 
						      andTarget:nil];
		}
	}
	else
	{
		LOG(@"Error failed to get picID from \n:%@", object);
	}
	
	NSNumber *userID = [object objectForKey:@"user"];
	
	if (CHECK_NUMBER(userID))
	{
		if (nil == [ProfileMananger getObjectWithNumberID:userID])
		{
			[ProfileMananger requestObjectWithNumberID:userID 
							andHandler:nil 
							 andTarget:nil];
		}
		
	}
	else
	{
		LOG(@"Error failed to get userID from \n:%@", object);
	}
}

- (void) handlerForArrayResult:(id)result
{
	[super handlerForArrayResult:result];
	
	
	
	NSMutableSet *newPicSet = [[NSMutableSet alloc] init];
	NSMutableSet *newUserSet = [[NSMutableSet alloc] init];
	
	for (NSDictionary *object in [result objectForKey:@"result"]) 
	{
		NSNumber *picID = [object valueForKey:@"pic"];
		
		if (CHECK_NUMBER(picID))
		{
			if (nil == [ImageManager getObjectWithNumberID:picID])
			{
				[newPicSet addObject:picID];
			}
		}
		else
		{
			LOG(@"Error failed to get picID from \n:%@", object);
		}
		
		NSNumber *userID = [object objectForKey:@"user"];
		
		if (CHECK_NUMBER(userID))
		{
			if (nil == [ProfileMananger getObjectWithNumberID:userID])
			{
				[newUserSet addObject:userID];
			}
		}
		else
		{
			LOG(@"Error failed to get userID from \n:%@", object);
		}	
	}
	
	// cache the new image info
	[ImageManager requestObjectWithNumberIDArray:[newPicSet allObjects]];
	
	// cacahe the new user info
	[ProfileMananger requestObjectWithNumberIDArray:[newUserSet allObjects]];

	[newUserSet release];
	[newPicSet release];
	
}

#pragma mark - overwrite get method

- (NSString *) getMethod
{
	return @"food.get";
}

#pragma mark - overwrite create method

- (NSString *) createMethod
{
	return @"food.create";
}

#pragma mark - overwrite delete method
- (NSString *) deleteMethod
{
	return @"food.delete";
}

+ (void) deleteObject:(NSNumber *)objectID withhandler:(SEL)handler andTarget:(id)target
{
	[EventManager deleteEventByFood:objectID];
	[UserFoodHistoryManager deleteHistoryByFood:objectID forUser:GET_USER_ID()];
	
	[super deleteObject:objectID withhandler:handler andTarget:target];
}

@end
