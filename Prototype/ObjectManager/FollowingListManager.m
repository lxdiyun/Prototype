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
#import "FansListManager.h"
#import "ProfileMananger.h"
#import "EventManager.h"

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
			self.createMethodString = @"friendship.follow";
			self.deleteMethodString = @"friendship.unfollow";
		}
	}
	
	return self;
}

#pragma mark - overwrite super class method - create

- (void) createMethodHandler:(id)result withListID:(NSString *)listID
{
	BOOL followUpdated = [[result valueForKey:@"result"] boolValue];
	
	if (followUpdated)
	{
		NSNumber *userID = [NSNumber numberWithInteger:[listID integerValue]];
		NSArray *userIDArray = [NSArray arrayWithObjects:userID, GET_USER_ID(), nil];
		
		[[self class] requestNewerWithListID:[GET_USER_ID() stringValue] 
					    andCount:1 
					 withHandler:nil 
					   andTarget:nil];
		[FansListManager requestNewerWithListID:listID 
					       andCount:1 
					    withHandler:nil 
					      andTarget:nil];
		[ProfileMananger requestObjectWithNumberIDArray:userIDArray];
	}
}

- (void) configCreateMethodParams:(NSMutableDictionary *)params 
			forObject:(NSDictionary *)object 
			   inList:(NSString *)listID
{
	[params setValue:[NSNumber numberWithInteger:[listID integerValue]] forKey:@"user"];;
}

+ (void) follow:(NSNumber *)userID with:(SEL)handler and:(id)target 
{
	@autoreleasepool 
	{
		[self requestCreateWithObject:nil 
				       inList:[userID stringValue] 
				  withHandler:handler 
				    andTarget:target];
	}
}

#pragma mark - overwrite super class method - delete

- (void) deleteMethodHandler:(id)result withListID:(NSString *)listID
{
	BOOL followUpdated = [[result valueForKey:@"result"] boolValue];
	
	if (followUpdated)
	{
		NSNumber *userID = [NSNumber numberWithInteger:[listID integerValue]];
		NSArray *userIDArray = [NSArray arrayWithObjects:userID, GET_USER_ID(), nil];
		
		[[self class] setObject:nil 
			   withStringID:listID 
				 inList:[GET_USER_ID() stringValue]];
		[FansListManager setObject:nil 
			      withStringID:[GET_USER_ID() stringValue] 
				    inList:listID];
		[ProfileMananger requestObjectWithNumberIDArray:userIDArray];
		[EventManager removeEventsForUser:userID];
	}
}

- (void) configDeleteMethodParams:(NSMutableDictionary *)params 
			forObject:(NSString *)objectID 
			   inList:(NSString *)listID 

{
	[params setValue:[NSNumber numberWithInteger:[listID integerValue]] forKey:@"user"];;
}

+ (void) unFollow:(NSNumber *)userID with:(SEL)handler and:(id)target 
{
	@autoreleasepool 
	{
		[self requestDeleteWithObject:nil 
				       inList:[userID stringValue] 
				  withHandler:handler 
				    andTarget:target];
	}
}

@end
