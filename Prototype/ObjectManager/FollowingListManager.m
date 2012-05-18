//
//  FollowingListManager.m
//  Prototype
//
//  Created by Adrian Lee on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FollowingListManager.h"

#import "Util.h"
#import "Message.h"

@implementation FollowingListManager

#pragma mark - singleton

DEFINE_SINGLETON(FollowingListManager);

#pragma mark - life circle

- (id) init
{
	self = [super init];
	
	if (self)
	{
		@autoreleasepool 
		{
			self.getMethodString = @"friendship.get_following";
		}
	}
	
	return self;
}

#pragma mark - create and delete

+ (void) follow:(NSNumber *)userID with:(SEL)handler and:(id)target 
{
	@autoreleasepool 
	{
		NSMutableDictionary *message = [[[NSMutableDictionary alloc] init] autorelease];
		NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
		
		[params setValue:userID forKey:@"user"];
		[message setValue:@"friendship.follow" forKey:@"method"];
		[message setValue:params forKey:@"params"];
		
		SEND_MSG_AND_BIND_HANDLER_WITH_PRIOIRY(message, target, handler, NORMAL_PRIORITY);
	}
}

+ (void) unFollow:(NSNumber *)userID with:(SEL)handler and:(id)target 
{
	@autoreleasepool 
	{
		NSMutableDictionary *message = [[[NSMutableDictionary alloc] init] autorelease];
		NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
		
		[params setValue:userID forKey:@"user"];
		[message setValue:@"friendship.unfollow" forKey:@"method"];
		[message setValue:params forKey:@"params"];
		
		SEND_MSG_AND_BIND_HANDLER_WITH_PRIOIRY(message, target, handler, NORMAL_PRIORITY);
	}
}

@end
