//
//  Util.h
//  Prototype
//
//  Created by Adrian Lee on 12/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#ifndef  _UTIL_H_
#define  _UTIL_H_

#import <Foundation/Foundation.h>

#import "HJObjManager.h"

// header, 32 bits long, 2 bits reserved and 30 bits for message length
static const uint32_t HEADER_SIZE = sizeof(uint32_t);
static const uint8_t HEADER_LENGTH_BITS = 30;
static const uint32_t HEADER_RESERVE_MASK = (0x3 << HEADER_LENGTH_BITS);
static const uint32_t HEADER_LENGTH_MASK = (0x1 << HEADER_LENGTH_BITS) - 1;
enum MESSAGE_TYPE
{
	JSON_MSG = 0x0,
	PING_PONG_MSG = 0x1,
	BINARY_MSG = 0x2,
	GOOGLE_BUF_MSG = 0x3,
	MAX_MSG = 0x4
};

@interface Util : NSObject
@end

// Message Util
uint32_t GET_MSG_ID(void);
// TODO remove string to data method which only for test
void CONVERT_MSG_STRING_TO_DATA(NSString* input_string, NSMutableData *output_data);
void CONVERT_MSG_DICTONARY_TO_DATA(NSDictionary *input_dict, NSMutableData * output_data);

// Operation Util
void PERFORM_OPERATION(NSOperation *operation); 

// Cache Util
void MANAGE_OBJ(id<HJMOUser> managedImage);

#endif
