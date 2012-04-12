//
//  MessageBinaryWriter.m
//  Prototype
//
//  Created by Adrian Lee on 1/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Message.h"

static NSMutableDictionary *gs_binary_pending_messages = nil;
static NSMutableArray *gs_binary_buffer_array = nil;

static void add_pending_message(NSArray *IDandBuffer)
{
	
}

NSData * POP_BINARY_BUFFER(void)
{
	if (nil == gs_binary_pending_messages)
	{
		gs_binary_pending_messages = [[NSMutableDictionary alloc] init];
	}
	
	NSData * popBuffer = nil;

	if (0 < [gs_binary_buffer_array count])
	{
		NSArray *IDandBuffer = [gs_binary_buffer_array objectAtIndex:0]; 
		NSString *ID = [IDandBuffer objectAtIndex:0]; 
		popBuffer = [IDandBuffer objectAtIndex:1];

		[gs_binary_pending_messages setValue:popBuffer forKey:ID];

		[gs_binary_buffer_array removeObjectAtIndex:0];
	}

	
	return nil;
}

void CONFIRM_BINARY_MESSAGE(NSString *ID)
{
	[gs_binary_pending_messages setValue:nil forKey:ID];
}

