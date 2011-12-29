//
//  MessageReader.m
//  Prototype
//
//  Created by Adrian Lee on 12/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Message.h"

#import "SBJson.h"
#import "Util.h"

static void json_message_handler(NSData *buffer_data);
static void pong_message_handler(NSData *buffer_data);

static NSMutableDictionary *gs_handler_dict = nil;
static CFRunLoopTimerRef gs_ping_timer = NULL;
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
	
	NSDictionary *messageDict = [jsonString JSONValue];
	
	[jsonString release];
	
	NSString *ID = [messageDict objectForKey:@"id"] ;
	NSArray *targetAndHandler = [gs_handler_dict valueForKey:ID];
	
	// TODO: Remove
	// CLOG(@"ID = %@ message = %@ dict = \n%@", ID, messageDict, gs_handler_dict);
	
	if (targetAndHandler)
	{
		[targetAndHandler retain];
		[gs_handler_dict setValue:nil forKey:ID];
		
		id target = [targetAndHandler objectAtIndex:0];
		NSString *handlerString = [targetAndHandler objectAtIndex:1];
		SEL handler = NSSelectorFromString(handlerString);
		if ([target respondsToSelector:handler])
		{
			[target performSelector:handler withObject:messageDict];
		}
		
		[targetAndHandler release];
	}
}

static void ping_timer_callback(CFRunLoopTimerRef timer, void *info)
{
	REQUEST_PING();
}

void pong_message_handler(NSData *bufferData)
{
	CLOG(@"Receive pong message!");
	if (NULL == gs_ping_timer)
	{
		CFRunLoopRef runLoop = CFRunLoopGetCurrent();
		// the timer will fire 50 seconds later 
		// set interval to a long time(double type max value) that the 
		// timer only fire once, and can be reactive later
		gs_ping_timer = CFRunLoopTimerCreate(kCFAllocatorDefault, 
						     CFAbsoluteTimeGetCurrent() + 50.0,
						     DBL_MAX,
						     0, 
						     0,
						     &ping_timer_callback, 
						     NULL);
		CFRunLoopAddTimer(runLoop, gs_ping_timer, kCFRunLoopCommonModes);
	}
	else
	{
		// reactive the timer
		CFRunLoopTimerSetNextFireDate(gs_ping_timer, 
					      CFAbsoluteTimeGetCurrent() + 50.0);
	}
}

void STOP_PING(void)
{
	if (NULL != gs_ping_timer)
	{
		CFRunLoopTimerSetNextFireDate(gs_ping_timer, DBL_MAX);
	}
}

void ADD_MESSAGE_HANLDER(SEL handler, id target, NSString *ID)
{
	if (nil != handler)
	{
		if (nil == gs_handler_dict)
		{
			gs_handler_dict = [[NSMutableDictionary alloc] init];
		}

		NSMutableArray *targetAndHandler = [[NSMutableArray alloc] init];
		[targetAndHandler addObject:target];
		[targetAndHandler addObject:NSStringFromSelector(handler)];

		[gs_handler_dict setValue:targetAndHandler forKey:ID];
		
		// TODO remove
		// CLOG(@"ID = %@ dict = \n%@", ID, gs_handler_dict);

		[targetAndHandler release];
	}
}

void HANDLE_MESSAGE(NSData * buffer_data)
{
	uint32_t header = CFSwapInt32HostToBig(*(uint32_t *)buffer_data.bytes);

	uint32_t messageType = (header >> HEADER_LENGTH_BITS);
	
	if (MAX_RESERVED_MSG > messageType)
	{
		gs_reserve_messgae_hanlder[messageType](buffer_data);
	}
	else
	{
		CLOG(@"Error - recevied unknow message type");
	}
}

