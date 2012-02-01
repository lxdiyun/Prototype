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

- (void) checkAndPerformResponderWithID:(NSString *)ID
{
	@autoreleasepool 
	{
		[super checkAndPerformResponderWithID:ID];
		
		NSDictionary *object = [self.objectDict valueForKey:ID];
		
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
}

- (void) checkAndPerformResponderWithStringIDArray:(NSArray *)IDArray
{
	@autoreleasepool 
	{
		[super checkAndPerformResponderWithStringIDArray:IDArray];
		
		NSMutableSet *newPicSet = [[NSMutableSet alloc] init];
		NSMutableSet *newUserSet = [[NSMutableSet alloc] init];
		
		for (NSString *ID in IDArray)
		{
			NSDictionary *object = [self.objectDict valueForKey:ID];
			NSNumber *picID = [[object valueForKey:@"obj"] valueForKey:@"pic"];
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
			
			NSNumber *userID = [[object valueForKey:@"obj"] objectForKey:@"user"];
			
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

@end
