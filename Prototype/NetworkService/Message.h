//
//  Message.h
//  Prototype
//
//  Created by Adrian Lee on 12/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#ifndef Prototype_Message_h
#define Prototype_Message_h

#import <Foundation/Foundation.h>

// header, 32 bits long, 2 bits reserved and 30 bits for message length
const static uint32_t HEADER_SIZE = sizeof(uint32_t);
const static uint8_t HEADER_LENGTH_BITS = 30;
const static uint32_t HEADER_RESERVE_MASK = (0x3 << HEADER_LENGTH_BITS);
const static uint32_t HEADER_LENGTH_MASK = (0x1 << HEADER_LENGTH_BITS) - 1;
enum RESERVED_MESSAGE_TYPE
{
	JSON_MSG = 0x0,
	PING_PONG_MSG = 0x1,
	BINARY_MSG = 0x2,
//	GOOGLE_BUF_MSG = 0x3,
	MAX_RESERVED_MSG
};

// reserved message ID for PING message or Normal Message daemon
// Please note that message use these ID to send will be not add 
// into pending message queue. So that the user must make sure 
// that the buffer for the message won't be release before network
// service send it.
typedef enum RESEVERED_MESSAGE_ID_ENUM
{
	DEAMON_MESSAGE_RESEVERED = -1,
	PING_MESSAGE_RESEVERED = 0x0,
	RESERVED_MESSAGE_MAX = 0x1
} RESEVERED_MESSAGE_ID;

typedef enum MESSAGE_PRIORITY_ENUM
{
	HIGHEST_PRIORITY = 0x0,		// For ping and login messages
	NORMAL_PRIORITY = 0x1,		// For normal message
	BINARY_PRIORITY = 0x2,		// For binary message
	PRIORITY_TYPE_MAX
} MESSAGE_PRIORITY;

// Auxiliary class Mesage Responder
@interface  MessageResponder: NSObject
@property (strong) id target;
@property (assign) SEL handler;
- (void) perform;
- (void) performWithObject:(id)object;
@end

// Message Writer
NSInteger GET_MSG_ID(void);
void SEND_MSG_AND_BIND_HANDLER_WITH_PRIOIRY_AND_ID(NSDictionary *messageDict, 
						   id target, 
						   SEL handler, 
						   MESSAGE_PRIORITY priority,
						   NSInteger ID);
NSInteger SEND_MSG_AND_BIND_HANDLER_WITH_PRIOIRY(NSDictionary *messageDict, 
						 id target, 
						 SEL handler, 
						 MESSAGE_PRIORITY priority);
void CONFIRM_MESSAGE(NSString *ID);
NSData * POP_BUFFER(void);
void ROLLBACK_ALL_PENDING_MESSAGE(void);
BOOL ROLLBACK_PENDING_MEESAGE(MESSAGE_PRIORITY priority, NSString *ID);

// Message Reader
void HANDLE_MESSAGE(NSData * bufferData);
void ADD_MESSAGE_RESPONDER(MessageResponder *responder, NSInteger ID);
void CLEAR_MESSAGE_HANDLER(void);

// PING PONG Message
void START_PING(void);
void STOP_PING(void);

// Binary Message
void UPLOAD_FILE(NSData *file, NSInteger file_ID);
void BIND_PROGRESS_VIEW_WITH_FILE_ID(UIProgressView *progressView, 
				     NSString *IDString);

#endif
