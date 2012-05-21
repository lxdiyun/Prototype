//
//  NotificationManager.m
//  Prototype
//
//  Created by Adrian Lee on 5/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NotificationManager.h"

#import "Util.h"
#import "DaemonManager.h"

static NSString *gs_fakeListID = nil;

@implementation NotificationManager

#pragma mark - singlton

DEFINE_SINGLETON(NotificationManager);

#pragma mark - life circle

- (id) init
{
	self = [super init];
	
	if (nil != self)
	{
		if (nil == gs_fakeListID)
		{
			gs_fakeListID = [[NSString alloc] initWithFormat:@"%d", 0x1];
		}

		self.getMethodString = @"notification.get_read";
		
		[self registerDaemonResponder];
	}
	
	return self;
}

- (void) dealloc
{
	[gs_fakeListID release];
	gs_fakeListID = nil;
	
	[super dealloc];
}

#pragma mark - send request message

+ (void) requestNewestCount:(uint32_t)count withHandler:(SEL)handler andTarget:(id)target
{
	[self requestNewestWithListID:gs_fakeListID 
			     andCount:count 
			  withHandler:handler 
			    andTarget:target];
}

+ (void) requestNewerCount:(uint32_t)count withHandler:(SEL)handler andTarget:(id)target
{
	return [self requestNewerWithListID:gs_fakeListID 
				   andCount:count 
				withHandler:handler 
				  andTarget:target];
}
+ (void) requestOlderCount:(uint32_t)count withHandler:(SEL)handler andTarget:(id)target
{
	return [self requestOlderWithListID:gs_fakeListID 
				   andCount:count 
				withHandler:handler 
				  andTarget:target];
}

+ (NSArray *) keyArray
{
	return [self keyArrayForList:gs_fakeListID]; 
}

+ (BOOL) isNewestUpdating
{
	@autoreleasepool 
	{
		return [self isUpdatingWithType:REQUEST_NEWER withListID:gs_fakeListID];
	}
}

+ (NSDate *) lastUpdatedDate
{
	return [self lastUpdatedDateForList:gs_fakeListID];
}

+ (NSDictionary *) getConversationWithUser:(NSString *)userID
{
	return [self getObject:userID inList:gs_fakeListID];
}

+ (NSDictionary *) getNotificationWith:(NSString *)ID
{
	return [self getObject:ID inList:gs_fakeListID];
}

#pragma mark - daemon

- (void) registerDaemonResponder
{
	[DaemonManager registerDaemon:@"notification.push_new_count" 
				 with:@selector(daemonMessageHandler:) 
				  and:self];
}

- (void) daemonMessageHandler:(NSDictionary *)message
{	

}


@end
