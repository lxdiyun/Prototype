//
//  MessageWriter.m
//  Prototype
//
//  Created by Adrian Lee on 12/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Message.h"
#import "MessagePrivate.h"

#import "JSONKit.h"

#import "NetworkService.h"
#import "Util.h"

static NSMutableArray *gs_buffer_array[PRIORITY_TYPE_MAX] = {nil};
static NSMutableDictionary *gs_pending_messages[PRIORITY_TYPE_MAX] = {nil};

#pragma mark - write message

static void convert_msg_dictonary_to_data(NSDictionary *input_dict, NSMutableData * output_data)
{
	convert_dictonary_to_json_data(input_dict, output_data);
}

void send_buffer_with_id_priority(NSData *buffer, 
				  const NSString *IDString, 
				  MESSAGE_PRIORITY prioirty)
{
	NSArray *IDAndBuffer = [[NSArray alloc] initWithObjects:IDString, buffer, nil];

	if (nil == gs_buffer_array[prioirty])
	{
		gs_buffer_array[prioirty] = [[NSMutableArray alloc] init];
	}

	[gs_buffer_array[prioirty] addObject:IDAndBuffer];

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
	ADD_MESSAGE_RESPONDER(responder, ID);

	// then send
	NSString *IDString = [[NSString alloc] initWithFormat:@"%u", ID];
	send_buffer_with_id_priority(message, IDString, priority);
	[IDString release];
}

static void add_pending_message(NSArray *IDAndBuffer, MESSAGE_PRIORITY priority)
{
	if (nil == gs_pending_messages[priority])
	{
		gs_pending_messages[priority] = [[NSMutableDictionary alloc] init];
	}

	NSString *ID = [IDAndBuffer objectAtIndex:0]; 

	if (RESEVERED_MESSAGE_ID != ID)
	{
		NSMutableArray *bufferArray = [gs_pending_messages[priority] valueForKey:ID];

		if (nil == bufferArray)
		{
			bufferArray = [[NSMutableArray alloc] init];

			[gs_pending_messages[priority] setValue:bufferArray forKey:ID];

			[bufferArray release];
		}

		[bufferArray addObject:IDAndBuffer];
	}	
}

#pragma mark - write meesage interface

uint32_t GET_MSG_ID(void)
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

void SEND_MSG_AND_BIND_HANDLER_WITH_PRIOIRY_AND_ID(NSDictionary *messageDict, 
						   id target, 
						   SEL handler, 
						   MESSAGE_PRIORITY priority,
						   uint32_t ID)
{
	@autoreleasepool 
	{
		NSNumber *IDNumber = [NSNumber numberWithUnsignedLong:ID];
		NSMutableData *data = [[[NSMutableData alloc] init] autorelease];
		NSMutableDictionary *dictWithID = [[messageDict mutableCopy] autorelease];
		MessageResponder *responder = [[[MessageResponder alloc] init] autorelease];
		responder.target = target;
		responder.handler = handler;
		
		[dictWithID setValue:IDNumber forKey:@"id"];
		
		convert_msg_dictonary_to_data(dictWithID, data);
		
		send_data_with_priority_and_responder(data, priority, responder, ID);
		
		
	}
}

uint32_t SEND_MSG_AND_BIND_HANDLER_WITH_PRIOIRY(NSDictionary *messageDict, 
						id target, 
						SEL handler, 
						MESSAGE_PRIORITY priority)
{
	uint32_t ID = GET_MSG_ID();
	SEND_MSG_AND_BIND_HANDLER_WITH_PRIOIRY_AND_ID(messageDict, 
						      target, 
						      handler, 
						      priority,
						      ID);
	return ID;
}

NSData * POP_BUFFER(void)
{
	NSData * popBuffer = nil;

	for (int priority = 0; priority < PRIORITY_TYPE_MAX; ++priority)
	{
		if (0 < [gs_buffer_array[priority] count])
		{
			NSArray *IDAndBuffer = [gs_buffer_array[priority] objectAtIndex:0]; 
			popBuffer = [IDAndBuffer objectAtIndex:1];

			add_pending_message(IDAndBuffer, priority);
			
			[gs_buffer_array[priority] removeObjectAtIndex:0];

			break;
		}
	}

	if (nil != popBuffer)
	{
		// TODO remove log
		NSMutableString *sendData = [[NSMutableString alloc] initWithFormat:@"\n"];
		for (int i = 0; i < popBuffer.length; ++i)
		{
			[sendData appendString:[NSString stringWithFormat:@"%2x ",*(uint8_t *)(popBuffer.bytes + i)]];
			if (0 == ((i + 1) % 16 ))
			{
				[sendData appendString:@"\n"];
			}
			
		}
		
		// CLOG(@"%@", sendData);
		
		[sendData release];
		
		if ((4 < popBuffer.length) && !(*(uint8_t *)(popBuffer.bytes) & (BINARY_MSG << 6)))
		{
			CLOG(@"%s", popBuffer.bytes + 4);
		}
	}

	return popBuffer;
}

void CONFIRM_MESSAGE(NSString *ID)
{
	for (int i = 0; i < PRIORITY_TYPE_MAX; ++i)
	{
		[gs_pending_messages[i] setValue:nil forKey:ID];
	}
}

BOOL ROLLBACK_PENDING_MEESAGE(MESSAGE_PRIORITY priority, NSString *ID)
{
	BOOL findTheMessages = NO;
	
	NSMutableArray *IDAndBufferArray = [gs_pending_messages[priority] valueForKey:ID];
	
	if (nil != IDAndBufferArray)
	{
		findTheMessages = YES;
		
		// roll back the message buffer in reversed buffer
		for (int i = [IDAndBufferArray count] - 1; i >= 0; --i)
		{
			NSArray *IDAndBuffer = [IDAndBufferArray objectAtIndex:i];
			[gs_buffer_array[priority] insertObject:IDAndBuffer atIndex:0];
		}
	}

	return findTheMessages;
}

void ROLLBACK_ALL_PENDING_MESSAGE(void)
{
	for (int priority = 0; priority < PRIORITY_TYPE_MAX; ++priority)
	{
		for (NSString *ID in [[gs_pending_messages[priority] allKeys] 
		     sortedArrayUsingFunction:ID_SORTER_REVERSE 
				      context:nil])
		{
			ROLLBACK_PENDING_MEESAGE(priority, ID);
		}

		[gs_pending_messages[priority] removeAllObjects];
	}
}

#pragma mark - binary Message

