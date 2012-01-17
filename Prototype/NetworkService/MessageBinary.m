//
//  MessageBinary.m
//  Prototype
//
//  Created by Adrian Lee on 1/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Message.h"
#import "MessagePrivate.h"

#import "NetworkService.h"
#import "Util.h"

/**
 * binary message format
 *  0 1 2 3 4 5 6 7 8 9 A B C D E F
 * +-------------------------------+
 * | Message Header (4 bytes) in   |
 * | big endian                    |
 * +-------------------------------+
 * | action byte   | action payload|
 * +-------------------------------+
 * | action payload                |
 * | ...                           |
 */

const static uint8_t BINARY_ACTION_BYTE_SIZE = sizeof(uint8_t);

const static uint32_t BINARY_MSG_WINDOW = 0x400; // 1024 bytes

typedef enum BINARY_MSG_ACTION_ENUM
{
	RESERVED_BINARY_ACTION_0 = 0x0,
	UPLOAD_FILE_ACTION = 0x1
} BINARY_MSG_ACTION;


#pragma mark - binary message request

static void generate_binary_message(NSMutableData *input_data, 
				    NSMutableData * output_data, 
				    BINARY_MSG_ACTION action)
{
	@autoreleasepool 
	{
		uint32_t header;
		uint8_t action_byte = action;
		
		if (nil != input_data)
		{
			header = CFSwapInt32HostToBig((input_data.length + BINARY_ACTION_BYTE_SIZE) | (BINARY_MSG << HEADER_LENGTH_BITS));
		}
		
		if (nil != output_data)
		{
			[output_data appendBytes:(void*)&header length:HEADER_SIZE];
			[output_data appendBytes:(void*)&action_byte 
					  length:BINARY_ACTION_BYTE_SIZE];
			[output_data appendData: input_data];
		}
	}			
}

/**
 * upload action payload format
 *  0 1 2 3 4 5 6 7 8 9 A B C D E F
 * +-------------------------------+
 * | file id (4 bytes) in big      |
 * | endian                        |
 * +-------------------------------+
 * | offset (4 bytes) in big endian|
 * |                               |
 * +-------------------------------+
 * | data                          |
 * | ...                           |
 */
void UPLOAD_FILE(NSData *file, uint32_t file_ID)
{
	if (nil == file)
	{
		CLOG(@"empty file to upload")
		return;
	}
	NSString *IDString = [[NSString alloc] initWithFormat:@"%u", file_ID];
	// cut file data into pieces with window size
	uint32_t offset = 0;
	uint32_t file_length = file.length;
	uint8_t pieces[BINARY_MSG_WINDOW + 1];
	uint32_t file_id_in_bigendian = CFSwapInt32HostToBig(file_ID);

	do
	{
		NSMutableData *payload = [[NSMutableData alloc] init];
		NSMutableData *binary_message = [[NSMutableData alloc] init];
		
		uint32_t offset_in_bigendian = CFSwapInt32HostToBig(offset);
		
		[payload appendBytes:(void*)&file_id_in_bigendian length:sizeof(file_id_in_bigendian)];
		[payload appendBytes:(void*)&offset_in_bigendian length:sizeof(offset_in_bigendian)];
		
		uint32_t lefted_bytes = file_length - offset;
		
		if (BINARY_MSG_WINDOW < lefted_bytes)
		{
			[file getBytes:pieces range:NSMakeRange(offset, BINARY_MSG_WINDOW)];
			[payload appendBytes:pieces length:BINARY_MSG_WINDOW];
		}
		else
		{
			[file getBytes:pieces range:NSMakeRange(offset, lefted_bytes)];
			[payload appendBytes:pieces length:lefted_bytes];
		}

		generate_binary_message(payload, binary_message, UPLOAD_FILE_ACTION);
		
		send_buffer_with_id_priority(binary_message, IDString, BINARY_PRIORITY);
		
		[binary_message release];
		[payload release];
		
		offset += BINARY_MSG_WINDOW;
	} while (offset < file_length);	
	
	[IDString release];
}

#pragma mark - binary message handler

void binary_message_handler(NSData *buffer_data)
{
	CLOG(@"receive binary mesage:%@", buffer_data);
}