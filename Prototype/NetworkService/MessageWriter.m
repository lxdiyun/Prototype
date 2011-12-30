//
//  MessageWriter.m
//  Prototype
//
//  Created by Adrian Lee on 12/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Message.h"

#import "SBJson.h"

#import "NetworkService.h"

#import "Util.h"

static CFRunLoopTimerRef gs_ping_timer = NULL;

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
		NSData *data = [input_dict JSONDataRepresentation];
		uint32_t header;
		
		if (nil != data)
		{
			header = CFSwapInt32HostToBig(data.length) | (JSON_MSG << HEADER_LENGTH_BITS);
		}
		
		// TODO remove log
		// CLOG(@"message %s", data.bytes);
		
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

static void send_data_and_bind_handler(NSData *message, id target, SEL handler, NSString *ID)
{
	// add handler first
	ADD_MESSAGE_HANLDER(handler, target, ID);

	// then send message
	[NetworkService requestSendMessage:message];
}

void SEND_MSG_AND_BIND_HANDLER(NSDictionary *messageDict, id target, SEL handler)
{
	@autoreleasepool 
	{
		NSString *ID = [[NSNumber numberWithUnsignedLong:get_msg_id()] stringValue];
		NSMutableData *data = [[[NSMutableData alloc] init] autorelease];
		NSMutableDictionary *completeDict = [[messageDict mutableCopy] autorelease];
		
		[completeDict setValue:ID forKey:@"id"];
		
		convert_msg_dictonary_to_data(completeDict, data);
		
		send_data_and_bind_handler(data, target, handler, ID);
	}
}

static void request_ping(CFRunLoopTimerRef timer, void *info)
{
	uint32_t pingMessage = CFSwapInt32HostToBig(PING_PONG_MSG << HEADER_LENGTH_BITS);
	
	NSData *data = [[NSData alloc] initWithBytes:(void *)&pingMessage length:HEADER_SIZE];
	
	[NetworkService requestSendMessage:data];
	
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
