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
#include "LoginManager.h"

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

static void error_handler(NSDictionary *errorMessage)
{
	NSString *error = [errorMessage valueForKey:@"error"];
	
	CLOG(@"Error = %@", error);
	
	if ([error isEqualToString:@"not logined"])
	{
		[LoginManager handleNotLoginMessage:errorMessage];
	}
}

void json_message_handler(NSData *message_data)
{
	@autoreleasepool
	{
		static JSONDecoder *decoder = nil;
		NSError *error = nil;
		
		if (nil == decoder)
		{
			decoder = [[JSONDecoder alloc] init];
		}

		NSDictionary *messageDict = [decoder objectWithData:message_data 
							      error:&error];
		
		if (nil != error)
		{
			CLOG(@"Error:json parser failed:%@", error);
			
			return;
		}

		NSString *ID = [[messageDict objectForKey:@"id"] stringValue];
		MessageResponder *responder = [gs_handler_dict valueForKey:ID];
		NSString *errorMessage = [messageDict valueForKey:@"error"];

		if (nil != errorMessage)
		{
			error_handler(messageDict);
		}

		// TODO: Remove comment to log
		CLOG(@"ID = %@ message = %@ dict = \n%@", ID, messageDict, gs_handler_dict);

		if (nil != ID)
		{
			NSInteger IDNumber = [ID integerValue];

			if (RESERVED_MESSAGE_MAX < IDNumber)
			{
				CONFIRM_MESSAGE(ID);
			}

			if (nil != responder)
			{
				[responder retain];

				if (RESERVED_MESSAGE_MAX < IDNumber)
				{
					[gs_handler_dict setValue:nil forKey:ID];
				}

				[responder performWithObject:messageDict];

				[responder release];
			}
		}
	}
}
