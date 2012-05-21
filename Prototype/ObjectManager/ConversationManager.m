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
	NSMutableDictionary *_unreadMessageFlags;
}

@property (strong) NSMutableDictionary *unreadMessageFlags;
@end

@implementation ConversationManager

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
		
		self.getMethodString = @"msg.get_conversation";
		self.createMethodString = @"msg.send";
	}
	
	return self;
}

- (void) dealloc
{
	self.unreadMessageFlags = nil;

	[super dealloc];
}

#pragma mark - class interface

+ (void) senMessage:(NSString *)message 
	     toUser:(NSString *)listID 
	withHandler:(SEL)handler 
	  andTarget:target
{
	@autoreleasepool 
	{
		NSMutableDictionary *newConversation = [[[NSMutableDictionary alloc] init] autorelease];
		
		[newConversation setValue:[NSNumber numberWithInt:[listID intValue]] forKey:@"user_id"];
		[newConversation setValue:message forKey:@"msg"];
		
		[self requestCreateWithObject:newConversation inList:listID withHandler:handler andTarget:target];
	}
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
		NSNumber *currentNewestKey = [[self class] newestKeyForList:listID];
		
		[super updateKeyArrayForList:listID withResult:result forward:forward];
		
		NSNumber *updatedNewestKey = [[self class] newestKeyForList:listID];

		if (!CHECK_EQUAL(currentNewestKey, updatedNewestKey))
		{
			[self.unreadMessageFlags setValue:[NSNumber numberWithBool:YES] forKey:listID];
		}
	}
}

#pragma mark - overwrite get method

- (void) configGetMethodParams:(NSMutableDictionary *)params forList:(NSString *)listID
{
	@autoreleasepool 
	{
		[params setValue:[NSNumber numberWithInt:[listID intValue]] forKey:@"user_id"];
	}
}

@end
