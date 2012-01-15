//
//  MessagePrivate.h
//  Prototype
//
//  Created by Adrian Lee on 1/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef Prototype_MessagePrivate_h
#define Prototype_MessagePrivate_h

#import <Foundation/Foundation.h>

// reserved message ID for PING message
const static NSString *RESEVERED_MESSAGE_ID = @"RESERVED_ID";
// handler dictionary for message reader and handler
extern NSMutableDictionary *gs_handler_dict;

// message writers
void send_buffer_with_id_priority(NSData *buffer, 
				  const NSString *IDString, 
				  MESSAGE_PRIORITY prioirty);

// json message
void convert_dictonary_to_json_data(NSDictionary *input_dict, NSMutableData * output_data);
void json_message_handler(NSData *buffer_data);

// ping pong message
void pong_message_handler(NSData *buffer_data);

// binary message 
void binary_message_handler(NSData *buffer_data);

#endif