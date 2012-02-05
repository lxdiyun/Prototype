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
	
}
@property (strong) NSString *message;
@end

@implementation ConversationManager

@synthesize message = _message;

#pragma mark - singleton

DEFINE_SINGLETON(ConversationManager);

#pragma mark - life circle

- (void) dealloc
{
	self.message = nil;

	[super dealloc];
}

#pragma mark - class interface
+ (void) createConversation:(NSString *)message forList:(NSString *)listID withHandler:(SEL)handler andTarget:target
{
	[[self getInstnace] setMessage:message];
	
	[self requestCreateWithListID:listID withHandler:handler andTarget:target];
}

#pragma mark - overwrite requsest get method

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

#pragma mark - overwrite super classs create method

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
