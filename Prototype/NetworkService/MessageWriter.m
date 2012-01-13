//
//  MessageWriter.m
//  Prototype
//
//  Created by Adrian Lee on 12/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Message.h"

#import "JSONKit.h"

#import "NetworkService.h"

#import "Util.h"

static CFRunLoopTimerRef gs_ping_timer = NULL;
static NSMutableArray *gs_buffer_array = nil;
static NSMutableDictionary *gs_pending_messages = nil;
const static NSString *RESEVERED_MESSAGE_ID = @"RESERVED_ID";

#pragma mark - write message

static uint32_t get_msg_id(void)
{
	const static uint32_t INIT_ID = 0x10;
	const static uint32_t MAX_ID = 0xFFFF;
	const static NSString *lock = @"GET_MSG_ID";
	static uint32_t s_id_count = INIT_ID;
	
	@synchronized(lock) 
	{
		uint32_t returnID = ++s_id_count;
		
		if (MAX_ID <= s_id_count)
		{
			s_id_count = INIT_ID;
		}
		
		return returnID;
	}
}

static void convert_dictonary_to_json_data(NSDictionary *input_dict, NSMutableData * output_data)
{
	@autoreleasepool 
	{
		NSData *data = [input_dict JSONData];
		uint32_t header;
		
		if (nil != data)
		{
			header = CFSwapInt32HostToBig(data.length) | (JSON_MSG << HEADER_LENGTH_BITS);
		}
		
		if (nil !=output_data)
		{
			[output_data appendBytes:(void*)&header length:HEADER_SIZE];
			[output_data appendData: data];
		}
	}			
}

static void convert_msg_dictonary_to_data(NSDictionary *input_dict, NSMutableData * output_data)
{	
	convert_dictonary_to_json_data(input_dict, output_data);
}

static void send_buffer_with_id_priority(NSData *buffer, 
					 const NSString *IDString, 
					 MESSAGE_PRIORITY prioirty)
{
	NSArray *IDAndBuffer = [[NSArray alloc] initWithObjects:IDString, buffer, nil];
	
	if (nil == gs_buffer_array)
	{
		gs_buffer_array = [[NSMutableArray alloc] init];
	}
	
	if (HIGHEST_PRIORITY == prioirty)
	{
		[gs_buffer_array insertObject:IDAndBuffer atIndex:0];
	}
	else
	{
	
		[gs_buffer_array addObject:IDAndBuffer];
	}
	
	[IDAndBuffer release];
	
	// request send
	[NetworkService requestSendMessage];
}

static void send_data_with_priority_and_responder(NSData *message, 
						  MESSAGE_PRIORITY priority,
						  MessageResponder *responder, 
						  uint32_t ID)
{
	START_NETWORK_INDICATOR();

	// add handler first
	ADD_MESSAGE_RESPOMDER(responder, ID);
	
	// then send
	NSString *IDString = [[NSString alloc] initWithFormat:@"%u", ID];
	send_buffer_with_id_priority(message, IDString, priority);
	[IDString release];
}

uint32_t SEND_MSG_AND_BIND_HANDLER_WITH_PRIOIRY(NSDictionary *messageDict, 
					    id target, 
					    SEL handler, 
					    MESSAGE_PRIORITY priority)
{
	@autoreleasepool 
	{
		uint32_t ID = get_msg_id();
		NSNumber *IDNumber = [NSNumber numberWithUnsignedLong:ID];
		NSMutableData *data = [[[NSMutableData alloc] init] autorelease];
		NSMutableDictionary *dictWithID = [[messageDict mutableCopy] autorelease];
		MessageResponder *responder = [[MessageResponder alloc] init];
		responder.target = target;
		responder.handler = handler;
									
		
		[dictWithID setValue:IDNumber forKey:@"id"];
		
		convert_msg_dictonary_to_data(dictWithID, data);
		
		send_data_with_priority_and_responder(data, priority, responder, ID);
		
		[responder release];
		
		return ID;
	}
}

NSData * POP_BUFFER(void)
{
	if (nil == gs_pending_messages)
	{
		gs_pending_messages = [[NSMutableDictionary alloc] init];
	}
	
	NSData * popBuffer = nil;
	
	if (0 < [gs_buffer_array count])
	{
		NSArray *IDandBuffer = [gs_buffer_array objectAtIndex:0]; 
		NSString *ID = [IDandBuffer objectAtIndex:0]; 
		popBuffer = [IDandBuffer objectAtIndex:1];
		
		if (RESEVERED_MESSAGE_ID != ID)
		{
			[gs_pending_messages setValue:popBuffer forKey:ID];
		}
		
		[gs_buffer_array removeObjectAtIndex:0];
	}
	
	// TODO remove log
	if (4 < popBuffer.length)
	{
		CLOG(@"%s", popBuffer.bytes + 4);
	}
	
	return popBuffer;
}

void CONFIRM_MESSAGE(NSString *ID)
{
	[gs_pending_messages setValue:nil forKey:ID];
}

void REQUEUE_PENDING_MESSAGE(void)
{
	for (NSString *ID in [gs_pending_messages allKeys])
	{
		NSData *messageBuffer = [gs_pending_messages valueForKey:ID];
		
		send_buffer_with_id_priority(messageBuffer, ID, NORMAL_PRIORITY);
		
		[gs_pending_messages setValue:nil forKey:ID];
	}
}

#pragma mark - PING Message

static void request_ping(CFRunLoopTimerRef timer, void *info)
{
	CLOG(@"request ping");
	
	uint32_t pingMessage = CFSwapInt32HostToBig(PING_PONG_MSG << HEADER_LENGTH_BITS);
	
	NSData *data = [[NSData alloc] initWithBytes:(void *)&pingMessage length:HEADER_SIZE];
	
	send_buffer_with_id_priority(data, RESEVERED_MESSAGE_ID, HIGHEST_PRIORITY);
	
	[NetworkService requestSendMessage];
	
	[data release];
}

void START_PING(void)
{
	if (NULL == gs_ping_timer)
	{
		CFRunLoopRef runLoop = CFRunLoopGetCurrent();
		// the ping timer will be fire 50 seconds later 
		// set interval to a long time(double type max value) that the 
		// timer only fire once, and can be reactive later
		gs_ping_timer = CFRunLoopTimerCreate(kCFAllocatorDefault, 
						     CFAbsoluteTimeGetCurrent() + 50.0,
						     DBL_MAX,
						     0, 
						     0,
						     &request_ping, 
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
