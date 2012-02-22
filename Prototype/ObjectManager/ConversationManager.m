//
//  ConversationManager.m
//  Prototype
//
//  Created by Adrian Lee on 2/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ConversationManager.h"

#import "Util.h"
#import "Message.h"

@interface ConversationManager () 
{
	NSString *_message;
	NSMutableDictionary *_unreadMessageFlags;
}

@property (strong) NSString *message;
@property (strong) NSMutableDictionary *unreadMessageFlags;
@end

@implementation ConversationManager

@synthesize message = _message;
@synthesize unreadMessageFlags = _unreadMessageFlags;

#pragma mark - singleton

DEFINE_SINGLETON(ConversationManager);

#pragma mark - life circle

- (void) reset
{
	@autoreleasepool 
	{
		self.unreadMessageFlags = [[[NSMutableDictionary alloc] init] autorelease];
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
	self.unreadMessageFlags = nil;

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

+ (void) cleanUnreadMessageCountForUser:(NSString *)userID
{
	@autoreleasepool 
	{
		[[[[self class] getInstnace] unreadMessageFlags] setValue:[NSNumber numberWithBool:NO] 
								    forKey:userID];
	}
	
}

+ (BOOL) hasUnreadMessageforUser:(NSString *)userID
{
	NSNumber *hasUnreadMessage = [[[[self class] getInstnace] unreadMessageFlags] 
				     valueForKey:userID];
	if (nil == hasUnreadMessage)
	{
		return 0;
	}
	
	return [hasUnreadMessage boolValue];
}

+ (NSInteger) newMessageCountForUser:(NSString *)userID
{
	NSNumber *newMessageCount = [[[[self class] getInstnace] unreadMessageFlags] 
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
	@autoreleasepool 
	{
		NSInteger currentNewestKey = [[self class] newestKeyForList:listID];
		
		[super updateKeyArrayForList:listID withResult:result forward:forward];
		
		NSInteger updatedNewestKey = [[self class] newestKeyForList:listID];

			
		if (currentNewestKey != updatedNewestKey)
		{
			[self.unreadMessageFlags setValue:[NSNumber numberWithBool:YES] forKey:listID];
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
