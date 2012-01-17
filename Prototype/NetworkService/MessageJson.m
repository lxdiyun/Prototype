//
//  MessageJson.m
//  Prototype
//
//  Created by Adrian Lee on 1/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#include "Message.h"
#include "MessagePrivate.h"

#include "JSONKit.h"

#include "Util.h"

#pragma mark -- json message converter

void convert_dictonary_to_json_data(NSDictionary *input_dict, NSMutableData * output_data)
{
	@autoreleasepool 
	{
		NSData *data = [input_dict JSONData];
		uint32_t header;
		
		if (nil != data)
		{
			header = CFSwapInt32HostToBig(data.length | (JSON_MSG << HEADER_LENGTH_BITS));
		}
		
		if (nil !=output_data)
		{
			[output_data appendBytes:(void*)&header length:HEADER_SIZE];
			[output_data appendData: data];
		}
	}			
}

#pragma mark - json message handler

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
	
	// TODO: Remove log
	CLOG(@"ID = %@ message = %@ dict = \n%@", ID, messageDict, gs_handler_dict);

	STOP_NETWORK_INDICATOR();
	CONFIRM_MESSAGE(ID);
	
	if (nil != responder)
	{
		[responder retain];
		[gs_handler_dict setValue:nil forKey:ID];
		
		[responder performWithObject:messageDict];
		
		[responder release];
	}
}