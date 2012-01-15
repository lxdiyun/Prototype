//
//  MessagePingPong.m
//  Prototype
//
//  Created by Adrian Lee on 1/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#include "Message.h"
#include "MessagePrivate.h"

#include <stdio.h>

#include "Util.h"
#include "NetworkService.h"

static CFRunLoopTimerRef gs_ping_timer = NULL;


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

#pragma mark - pong handler

void pong_message_handler(NSData *bufferData)
{
	CLOG(@"Receive pong message!");
	
	START_PING();
}