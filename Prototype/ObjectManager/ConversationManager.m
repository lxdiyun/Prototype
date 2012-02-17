//
//  ConversationManager.m
//  Prototype
//
//  Created by Adrian Lee on 2/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ConversationManager.h"

#import "Util.h"

@interface ConversationManager () 
{
	NSString *_message;
	NSMutableDictionary *_messageNewCountDict;
	
}
@property (strong) NSString *message;
@property (strong) NSMutableDictionary *messageNewCountDict;
@end

@implementation ConversationManager

@synthesize message = _message;
@synthesize messageNewCountDict = _messageNewCountDict;

#pragma mark - singleton

DEFINE_SINGLETON(ConversationManager);

#pragma mark - life circle

- (void) reset
{
	@autoreleasepool 
	{
		self.messageNewCountDict = [[[NSMutableDictionary alloc] init] autorelease];
	}
}

- (id) init
{
	self = [super init];
	
	if (nil != self)
	{
		[self reset];
	}
	
	return self;
}

- (void) dealloc
{
	self.message = nil;
	self.messageNewCountDict = nil;

	[super dealloc];
}

#pragma mark - class interface

+ (void) senMessage:(NSString *)message 
	     toUser:(NSString *)listID 
	withHandler:(SEL)handler 
	  andTarget:target
{
	[[self getInstnace] setMessage:message];
	
	[self requestCreateWithListID:listID withHandler:handler andTarget:target];
}

+ (void) setHasNewMessageCount:(NSInteger)count forUser:(NSString *)userID
{
	@autoreleasepool 
	{
		[[[[self class] getInstnace] messageNewCountDict] setValue:[NSNumber numberWithInteger:count] 
								    forKey:userID];
	}
}

+ (NSInteger) newMessageCountForUser:(NSString *)userID
{
	NSNumber *newMessageCount = [[[[self class] getInstnace] messageNewCountDict] 
				     valueForKey:userID];
	
	if (nil == newMessageCount)
	{
		return 0;
	}
	
	return [newMessageCount integerValue];
}

#pragma mark - overwrite save and restore

+ (void) reset
{
	[super reset];
	
	@autoreleasepool 
	{
		[[self getInstnace] reset];
	}
}

#pragma mark - overwrite update key

- (void) updateKeyArrayForList:(NSString *)listID 
		    withResult:(NSArray *)result 
		       forward:(BOOL)forward
{
	uint32_t currentNewestID  = [self getNewestKeyWithlistID:listID];
	uint32_t currentIDCount = [[[self objectKeyArrayDict] valueForKey:listID] count];
	uint32_t updatedNewestID;
	uint32_t updatedIDCount;
	
	[super updateKeyArrayForList:listID withResult:result forward:forward];
	
	updatedNewestID = [self getNewestKeyWithlistID:listID];
	updatedIDCount = [[[self objectKeyArrayDict] valueForKey:listID] count];
	
	if (currentNewestID != updatedNewestID)
	{
		NSInteger newMessageCount = updatedIDCount - currentIDCount;
		
		LOG(@"new message count = %d", newMessageCount);

		if (newMessageCount > 0)
		{
			[[self class] setHasNewMessageCount:newMessageCount forUser:listID];
		}
		else
		{
			[[self class] setHasNewMessageCount:0 forUser:listID];
		}
	}
}


#pragma mark - overwrite get method

- (NSString *) getMethod
{
	return @"msg.get_conversation";
}

- (void) setGetMethodParams:(NSMutableDictionary *)params forList:(NSString *)listID
{
	@autoreleasepool 
	{
		[params setValue:[NSNumber numberWithInt:[listID intValue]] forKey:@"user_id"];
	}
}

#pragma mark - overwrite create method

- (NSString *) createMethod
{
	return @"msg.send";
}

- (void) setCreateMethodParams:(NSMutableDictionary *)params forList:(NSString *)listID
{
	@autoreleasepool 
	{
		[params setValue:[NSNumber numberWithInt:[listID intValue]] forKey:@"user_id"];
		[params setValue:self.message forKey:@"msg"];
	}
}

@end
