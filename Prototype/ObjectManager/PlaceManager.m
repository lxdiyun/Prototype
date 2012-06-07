//
//  PlaceManager.m
//  Prototype
//
//  Created by Adrian Lee on 3/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlaceManager.h"

#import "Util.h"
#import "FoodManager.h"

@implementation PlaceManager

#pragma mark - singleton
DEFINE_SINGLETON(PlaceManager);

#pragma mark - overwrite get method

- (NSString *) getMethod
{
	return @"place.get";
}

- (void) handlerForSingleResult:(id)result
{
	[super handlerForSingleResult:result];
	
	NSArray *foods = [[result valueForKey:@"result"] valueForKey:@"foods"];
	
	if (0 < [foods count])
	{
		[FoodManager requestObjectWithNumberIDArray:foods];
	}
	
}

- (void) handlerForArrayResult:(id)result
{
	[super handlerForArrayResult:result];
	
	NSMutableArray *foodIDArray = [[NSMutableArray alloc] init];
	
	for (NSDictionary *object in [result objectForKey:@"result"]) 
	{
		NSArray *foods = [object valueForKey:@"foods"];
		
		if (0 < foods.count)
		{
			[foodIDArray addObjectsFromArray:foods];
		}
	}
	
	if (0 < foodIDArray.count)
	{
		[FoodManager requestObjectWithNumberIDArray:foodIDArray];
	}
	
	[foodIDArray release];
}

#pragma mark - overwrite create method

- (NSString *) createMethod
{
	return @"place.create";
}

+ (void) createPlace:(NSDictionary *)placeObject withHandler:(SEL)handler andTarget:(id)target
{
	[[self getInstnace] setCreateParams:placeObject];
	
	[self createObjectWithHandler:handler andTarget:target];
}

#pragma mark - overwrite update method

- (NSString *) updateMethod
{
	return @"place.update";
}

#pragma mark - overwrite get and set

+ (NSDictionary *) getObjectWithStringID:(NSString *)ID
{
	if (CHECK_STRING(ID))
	{
		// refresh object from server 
		[self requestObjectWithStringID:ID andHandler:nil andTarget:nil];
		
		return [[[self getInstnace] objectDict] valueForKey:ID];
	}
	else
	{
		return nil;
	}
}

@end
