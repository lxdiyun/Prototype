//
//  CommentManager.m
//  Prototype
//
//  Created by Adrian Lee on 1/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CommentManager.h"

#import "ProfileMananger.h"
#import "Util.h"

@implementation CommentManager

#pragma mark - overwrite super class method
#pragma mark - overwrite handler

- (void) messageHandler:(id)dict withListID:(NSString *)ID
{
	[super messageHandler:dict withListID:ID];
	
	NSDictionary *messageDict = [(NSDictionary*)dict retain];
	NSMutableSet *newUserSet = [[NSMutableSet alloc] init];
	
	for (NSDictionary *object in [messageDict objectForKey:@"result"]) 
	{
		NSNumber *userID = [object valueForKey:@"user"];
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
	
	// buffer the new image info
	[ProfileMananger requestObjectWithNumberIDArray:[newUserSet allObjects]];
	
	[newUserSet release];
	[messageDict release];
}


#pragma mark - overwrite requsest get method

- (NSString *) getMethod
{
	return @"comment.get";
}

@end
