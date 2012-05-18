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

- (void) handlerForSingleResult:(id)result;
{
	[super handlerForSingleResult:result];
	
	NSArray *foods = [result valueForKey:@"foods"];
	
	if (0 < [foods count])
	{
		[FoodManager requestObjectWithNumberIDArray:foods];
	}
	
}

- (void) handlerForArrayResult:(id)result
{
	[super handlerForArrayResult:result];
	
	for (NSDictionary *object in [result objectForKey:@"result"]) 
	{
		NSArray *foods = [object valueForKey:@"foods"];
		
		if (0 < [foods count])
		{
			[FoodManager requestObjectWithNumberIDArray:foods];
		}
	}
}

#pragma mark - overwrite create method

- (NSString *) createMethod
{
	return @"place.create";
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
