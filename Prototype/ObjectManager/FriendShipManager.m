//
//  FriendShipManager.m
//  Prototype
//
//  Created by Adrian Lee on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FriendShipManager.h"

#import "ProfileMananger.h"
#import "Util.h"

@implementation FriendShipManager

#pragma mark - overwrite super class method
#pragma mark - overwrite handler

- (void) getMethodHandler:(id)result withListID:(NSString *)listID forward:(BOOL)forward
{
	@autoreleasepool 
	{
		NSDictionary *messageDict = [(NSDictionary*)result retain];
		NSDictionary *listDict = [self.objectDict valueForKey:listID];
		NSMutableArray *newUserIDArray = [[NSMutableArray alloc] init];
		
		if (nil == listDict)
		{
			listDict = [[NSMutableDictionary alloc] init];
			[self.objectDict setValue:listDict forKey:listID];
			[listDict autorelease];
		}
		
		for (NSDictionary *object in [messageDict objectForKey:@"result"]) 
		{
			NSNumber *userID = [object valueForKey:@"user"];
			NSNumber *sortIndex = [object valueForKey:@"id"];
			
			[listDict setValue:sortIndex forKey:[userID stringValue]];
			
			if (nil == [ProfileMananger getObjectWithNumberID:userID])
			{
				[newUserIDArray addObject:userID];
			}
		}
		
		// update object key array
		[self updateKeyArrayForList:listID withResult:nil forward:forward];
		
		if (0 < newUserIDArray.count)
		{
			[ProfileMananger requestObjectWithNumberIDArray:newUserIDArray];
		}

		[newUserIDArray release];
		[messageDict release];
	}
}

#pragma mark - overwrite super classs get method

- (void) configGetMethodParams:(NSMutableDictionary *)params forList:(NSString *)listID
{
	@autoreleasepool 
	{
		[params setValue:[NSNumber numberWithInt:[listID intValue]] forKey:@"user"];
	}
	
}

@end
