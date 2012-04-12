//
//  PlaceManager.m
//  Prototype
//
//  Created by Adrian Lee on 3/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlaceManager.h"

#import "Util.h"

@implementation PlaceManager

#pragma mark - singleton
DEFINE_SINGLETON(PlaceManager);

#pragma mark - overwrite get method

- (NSString *) getMethod
{
	return @"place.get";
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

@end
