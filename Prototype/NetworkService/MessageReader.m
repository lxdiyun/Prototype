//
//  MessageReader.m
//  Prototype
//
//  Created by Adrian Lee on 12/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Message.h"

#import "JSONKit.h"

#import "Util.h"

static void json_message_handler(NSData *buffer_data);
static void pong_message_handler(NSData *buffer_data);

static NSMutableDictionary *gs_handler_dict = nil;
static void (* const gs_reserve_messgae_hanlder[MAX_RESERVED_MSG]) (NSData *buffer_data) = 
{
	json_message_handler,		// JSON_MSG
	pong_message_handler		// PING_PONG_MSG
};

void json_message_handler(NSData *buffer_data)
{
	uint32_t header = CFSwapInt32BigToHost(*(uint32_t *)buffer_data.bytes);
	uint32_t messageLength  = header & HEADER_LENGTH_MASK;
	NSString *jsonString = [[NSString alloc] initWithBytes:(buffer_data.bytes + HEADER_SIZE) 
							length:messageLength 
						      encoding:NSASCIIStringEncoding];	
	
	NSDictionary *messageDict = [jsonString objectFromJSONString];
	
	[jsonString release];
	
	NSString *ID = [[messageDict objectForKey:@"id"] stringValue];
	MessageResponder *responder = [gs_handler_dict valueForKey:ID];
	

	STOP_NETWORK_INDICATOR();
	CONFIRM_MESSAGE(ID);
	
	// TODO: Remove log
	// CLOG(@"ID = %@ message = %@ dict = \n%@", ID, messageDict, gs_handler_dict);
	
	if (nil != responder)
	{
		[responder retain];
		[gs_handler_dict setValue:nil forKey:ID];
		
		id target = responder.target;
		SEL handler = responder.handler;
		
		if ([target respondsToSelector:handler])
		{
			[target performSelector:handler withObject:messageDict];
		}
		
		[responder release];
	}
}

void pong_message_handler(NSData *bufferData)
{
	// TODO remove log
	CLOG(@"Receive pong message!");
	
	START_PING();
}

void CLEAR_MESSAGE_HANDLER(void)
{
	for (NSString *ID in [gs_handler_dict allKeys])
	{
		NSArray *targetAndHandler = [gs_handler_dict valueForKey:ID];
		
		id target = [targetAndHandler objectAtIndex:0];
		NSString *handlerString = [targetAndHandler objectAtIndex:1];
		SEL handler = NSSelectorFromString(handlerString);
		if ([target respondsToSelector:handler])
		{
			[target performSelector:handler withObject:nil];
		}
		
		STOP_NETWORK_INDICATOR();
		CONFIRM_MESSAGE(ID);
		
		[gs_handler_dict setValue:nil forKey:ID];
	}
}

void ADD_MESSAGE_RESPOMDER(MessageResponder *responder, uint32_t ID)
{
	if ((nil != responder.target) && (nil != responder.handler))
	{
		if (nil == gs_handler_dict)
		{
			gs_handler_dict = [[NSMutableDictionary alloc] init];
		}

		NSString *IDString = [[NSString alloc] initWithFormat:@"%u", ID];

		[gs_handler_dict setValue:responder forKey:IDString];

		[IDString release];
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


@interface  MessageResponder () 
{
	id _target;
	SEL _handler;
}
@end

@implementation MessageResponder
@synthesize target = _target;
@synthesize handler = _handler;
@end
