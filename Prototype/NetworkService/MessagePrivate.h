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

// handler dictionary for message reader and handler
extern NSMutableDictionary *gs_handler_dict;

// message writers
void send_buffer_with_id_priority(NSData *buffer, 
				  const NSString *IDString, 
				  MESSAGE_PRIORITY prioirty);
uint32_t pending_message_count(MESSAGE_PRIORITY priority, NSString *ID);

// json message
void convert_dictonary_to_json_data(NSDictionary *input_dict, NSMutableData * output_data);
void json_message_handler(NSData *message_data);

// ping pong message
void pong_message_handler(NSData *message_data);

// binary message 
void binary_message_handler(NSData *message_data);
void update_upload_progress(NSString *IDString);
void clean_progress(NSString *IDString);

#endif
