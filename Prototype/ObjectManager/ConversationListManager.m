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
#import "ConversationPage.h"
#import "ConversationDetailPage.h"

static NSString *gs_fakeListID = nil;

@interface ConversationListManager () 
{
}
- (void) bindDaemonResponder;
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
			
			[self bindDaemonResponder];
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

+ (BOOL) isNewerUpdating
{
	@autoreleasepool 
	{
		return [self isUpdatingWithType:REQUEST_NEWER withListID:gs_fakeListID];
	}
}

+ (NSDate *)lastUpdatedDate
{
	return [self lastUpdatedDateForList:gs_fakeListID];
}

+ (NSDictionary *) getConversationWithUser:(NSString *)userID
{
	return [self getObject:userID inList:gs_fakeListID];
}

#pragma mark - overwrite handler

+ (void) updateUnreadMessage
{
	NSArray *keyArray = [self keyArray];
	NSInteger totalUnreadMessage = 0;
	
	for (NSString *key in keyArray)
	{
		NSDictionary *conversation = [self getConversationWithUser:key];
		
		totalUnreadMessage += [[conversation valueForKey:@"unread_count"] integerValue];
	}
	
	[ConversationPage updateBage:totalUnreadMessage];
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

#pragma mark - overwrite requsest get method

- (NSString *) getMethod
{
	return @"msg.get_conversation_list";
}

- (void) setGetMethodParams:(NSMutableDictionary *)params forList:(NSString *)listID
{
	// do nothing
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

- (void) bindDaemonResponder
{
	MessageResponder *responder = [[MessageResponder alloc] init];
	
	responder.handler = @selector(daemonMessageHandler:);
	responder.target = self;
	
	ADD_MESSAGE_RESPONDER(responder, CONVERSATION_DAEMON);
	
	[responder release];
}

- (void) daemonMessageHandler:(NSDictionary *)message
{	
	NSString *method = [message valueForKey:@"method"];
	
	if ([method isEqualToString:@"msg.push"])
	{
		NSDictionary *params  = [message valueForKey:@"params"];
		NSString *userID = [[[params valueForKey:@"msg"] valueForKey:@"sender"] stringValue];
		
		if (![ConversationDetailPage newPushMessageForUser:userID])
		{
			[ConversationPage updateConversationList];
		}
	}
}


@end
