//
//  MapManager.m
//  Prototype
//
//  Created by Adrian Lee on 3/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MapManager.h"

#import "Util.h"

@implementation MapManager

#pragma mark - singelton
DEFINE_SINGLETON(MapManager);

#pragma mark - overwrite super class method
#pragma mark - overwrite super classs get method

- (NSString *) getMethod
{
	return @"map.get_list";
}

- (void) setGetMethodParams:(NSMutableDictionary *)params forList:(NSString *)listID
{
	@autoreleasepool 
	{
		// map list against special user
		[params setValue:[NSNumber numberWithInt:[listID intValue]] forKey:@"user"];
	}
}

#pragma mark - overwrite super classs create method

- (NSString *) createMethod
{
	LOG(@"Error no create method in map list manager");
	
	return nil;
}

- (void) setCreateMethodParams:(NSMutableDictionary *)params forList:(NSString *)listID
{
	// no params is needed, server will create the map accroding to the login user id
}

@end
