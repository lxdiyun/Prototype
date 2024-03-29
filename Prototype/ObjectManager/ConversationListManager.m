//
//  ConversationListManager.m
//  Prototype
//
//  Created by Adrian Lee on 2/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ConversationListManager.h"

#import "Util.h"
#import "ProfileMananger.h"
#import "Message.h"
#import "ConversationDetailPage.h"
#import "DaemonManager.h"
#import "NewsPage.h"

static NSString *gs_fakeListID = nil;

@interface ConversationListManager () 
{
}
@end

@implementation ConversationListManager


#pragma mark - singleton

DEFINE_SINGLETON(ConversationListManager);

#pragma mark - life circle

- (id) init
{
	self = [super init];
	
	if (self)
	{
		@autoreleasepool 
		{
			if (nil == gs_fakeListID)
			{
				gs_fakeListID = [[NSString alloc] initWithFormat:@"%d", 0x1];
			}
			
			self.getMethodString = @"msg.get_conversation_list";
			
			[self registerDaemonResponder];
			[[self class] checkNew];
		}
		
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

#pragma mark - interface

+ (NSArray *) keyArray
{
	return [self keyArrayForList:gs_fakeListID]; 
}

+ (BOOL) isNewestUpdating
{
	@autoreleasepool 
	{
		return [self isUpdatingWithType:REQUEST_NEWEST withListID:gs_fakeListID];
	}
}

+ (NSDate *) lastUpdatedDate
{
	return [self lastUpdatedDateForList:gs_fakeListID];
}

+ (NSDictionary *) getConversationWith:(NSString *)ID
{
	return [self getObject:ID inList:gs_fakeListID];
}

+ (void) checkNew
{
	[self requestNewestCount:20 withHandler:nil andTarget:nil];
}

#pragma mark - overwrite handler

+ (void) updateUnreadMessage
{
	NSArray *keyArray = [self keyArray];
	NSInteger totalUnreadMessage = 0;
	
	for (NSString *key in keyArray)
	{
		NSDictionary *conversation = [self getConversationWith:key];
		
		totalUnreadMessage += [[conversation valueForKey:@"unread_count"] integerValue];
	}
	
	[NewsPage setUnreadMessageCount:totalUnreadMessage];
}

- (void) getMethodHandler:(id)dict withListID:(NSString *)ID forward:(BOOL)forward
{
	[super getMethodHandler:dict withListID:ID forward:forward];
	
	NSDictionary *messageDict = [(NSDictionary*)dict retain];
	NSMutableSet *newUserSet = [[NSMutableSet alloc] init];
	
	for (NSDictionary *object in [messageDict objectForKey:@"result"]) 
	{
		NSNumber *userID = [object objectForKey:@"target"];
		
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
	
	
	// cacahe the new user info
	[ProfileMananger requestObjectWithNumberIDArray:[newUserSet allObjects]];
	
	// update unread message
	[[self class ] updateUnreadMessage];
	
	[newUserSet release];
	[messageDict release];
}


#pragma mark - overwrite  key array

- (void) updateKey:(NSString *)key inArray:(NSMutableArray *)array forward:(BOOL)forward
{
	NSMutableArray *reomveKeyArray = [[NSMutableArray alloc] init];
	for (NSUInteger i = 0; i < array.count; ++i)
	{
		if ([key isEqualToString:[array objectAtIndex:i]])
		{
			[reomveKeyArray addObject:[NSNumber numberWithUnsignedInt:i]];
		}
	}
	
	for (NSNumber *index in reomveKeyArray)
	{
		[array removeObjectAtIndex:[index unsignedIntegerValue]];
	}
	
	if (forward)
	{
		[array addObject:key];
	}
	else
	{
		[array insertObject:key atIndex:0];
	}
	
	[reomveKeyArray release];
}

- (void) updateKeyArrayForList:(NSString *)listID withResult:(NSArray *)result forward:(BOOL)forward
{
	@autoreleasepool 
	{
		NSMutableArray *keyArray = [[[[self class] keyArray] mutableCopy] autorelease];
		
		if (nil == keyArray)
		{
			keyArray = [[[NSMutableArray alloc] init] autorelease];
		}
		
		for (NSDictionary *object in result) 
		{
			NSString *key = [[object valueForKey:@"id"] stringValue];
			[self updateKey:key inArray:keyArray forward:forward];
		}
		
		[self.objectKeyArrayDict setValue:keyArray forKey:listID];
	}
}

#pragma mark - daemon

- (void) registerDaemonResponder
{
	[DaemonManager registerDaemon:@"msg.push" 
				 with:@selector(daemonMessageHandler:) 
				  and:self];
}

- (void) daemonMessageHandler:(NSDictionary *)message
{	
	NSDictionary *params  = [message valueForKey:@"params"];
	NSString *userID = [[[params valueForKey:@"msg"] valueForKey:@"sender"] stringValue];
	
	if (![ConversationDetailPage newPushMessageForUser:userID])
	{
		[NewsPage updateMessage];
	}
}


@end
