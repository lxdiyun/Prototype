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
	NSMutableDictionary *_hasNewMessageDict;
	
}
@property (strong) NSString *message;
@property (strong) NSMutableDictionary *hasNewMesssageDict;
@end

@implementation ConversationManager

@synthesize message = _message;
@synthesize hasNewMesssageDict = _hasNewMessageDict;

#pragma mark - singleton

DEFINE_SINGLETON(ConversationManager);

#pragma mark - life circle

- (void) reset
{
	@autoreleasepool 
	{
		self.hasNewMesssageDict = [[[NSMutableDictionary alloc] init] autorelease];
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
	self.hasNewMesssageDict = nil;

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

+ (void) setHasNewMessage:(BOOL)flag forUser:(NSString *)userID
{
	@autoreleasepool 
	{
		[[[[self class] getInstnace] hasNewMesssageDict] setValue:[NSNumber numberWithBool:flag] 
								   forKey:userID];
	}
}

+ (BOOL) hasNewMessageForUser:(NSString *)userID
{
	NSNumber *hasNewMessage = [[[[self class] getInstnace] hasNewMesssageDict] 
			       valueForKey:userID];
	
	if (nil == hasNewMessage)
	{
		return YES;
	}
	
	return [hasNewMessage boolValue];
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
	uint32_t updatedNewestID;
	
	[super updateKeyArrayForList:listID withResult:result forward:forward];
	
	updatedNewestID = [self getNewestKeyWithlistID:listID];
	
	if (currentNewestID != updatedNewestID)
	{
		[[self class] setHasNewMessage:YES forUser:listID];
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
