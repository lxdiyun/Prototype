//
//  MessageReader.m
//  Prototype
//
//  Created by Adrian Lee on 12/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Message.h"
#import "MessagePrivate.h"

#import "JSONKit.h"

#import "Util.h"

// handler dictionary for message reader and handler
NSMutableDictionary *gs_handler_dict = nil;

static void (* const gs_reserve_messgae_hanlder[MAX_RESERVED_MSG]) (NSData *buffer_data) = 
{
	json_message_handler,		// JSON_MSG
	pong_message_handler,		// PING_PONG_MSG
	binary_message_handler		// BINARY_MSG
};

void CLEAR_MESSAGE_HANDLER(void)
{
	for (NSString *ID in [gs_handler_dict allKeys])
	{
		MessageResponder *responder = [gs_handler_dict valueForKey:ID];
		
		[responder performWithObject:nil];
		
		STOP_NETWORK_INDICATOR();
		CONFIRM_MESSAGE(ID);
		
		[gs_handler_dict setValue:nil forKey:ID];
	}
}

void HANDLE_MESSAGE(NSData * buffer_data)
{
	uint32_t header = CFSwapInt32HostToBig(*(uint32_t *)buffer_data.bytes);

	uint32_t messageType = (header >> HEADER_LENGTH_BITS);
	
	if (MAX_RESERVED_MSG > messageType)
	{
		@autoreleasepool 
		{
			gs_reserve_messgae_hanlder[messageType](buffer_data);
		}
	}
	else
	{
		CLOG(@"Error - recevied unknow message type");
	}
}

void ADD_MESSAGE_RESPONDER(MessageResponder *responder, NSInteger ID)
{
	if ((nil != responder.target) && (nil != responder.handler))
	{
		if (nil == gs_handler_dict)
		{
			gs_handler_dict = [[NSMutableDictionary alloc] init];
		}
		
		NSString *IDString = [[NSString alloc] initWithFormat:@"%d", ID];
		
		[gs_handler_dict setValue:responder forKey:IDString];
		
		[IDString release];
	}
}

#pragma mark - class Message Responder

@interface  MessageResponder () 
{
	id _target;
	SEL _handler;
}
@end

@implementation MessageResponder
@synthesize target = _target;
@synthesize handler = _handler;

- (void) perform
{
	if ([self.target respondsToSelector:self.handler])
	{
		@autoreleasepool 
		{
			[self.target performSelector:self.handler];
		}
	}
}

- (void) performWithObject:(id)object
{
	if ([self.target respondsToSelector:self.handler])
	{
		@autoreleasepool 
		{
			[self.target performSelector:self.handler withObject:object];
		}
	}
}

- (void) dealloc
{
	self.target = nil;
	self.handler = nil;
	
	[super dealloc];
}
@end
