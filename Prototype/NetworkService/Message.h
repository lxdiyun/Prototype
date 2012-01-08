//
//  Message.h
//  Prototype
//
//  Created by Adrian Lee on 12/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
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
//	BINARY_MSG = 0x2,
//	GOOGLE_BUF_MSG = 0x3,
	MAX_RESERVED_MSG
};

typedef enum MESSAGE_PRIORITY_ENUM
{
	HIGHEST_PRIORITY = 0x1,
	NORMAL_PRIORITY = 0x2
}MESSAGE_PRIORITY;

@interface  MessageResponder: NSObject
@property (strong) id target;
@property (assign) SEL handler;
- (void) perform;
- (void) performWithObject:(id)object;
@end

// Message Writer
uint32_t SEND_MSG_AND_BIND_HANDLER_WITH_PRIOIRY(NSDictionary *messageDict, 
					    id target, 
					    SEL handler, 
					    MESSAGE_PRIORITY priority);
void CONFIRM_MESSAGE(NSString *ID);
NSData * POP_BUFFER(void);
void REQUEUE_PENDING_MESSAGE(void);
void START_PING(void);
void STOP_PING(void);

// Message Reader
void HANDLE_MESSAGE(NSData * bufferData);
void ADD_MESSAGE_RESPOMDER(MessageResponder *responder, uint32_t ID);
void CLEAR_MESSAGE_HANDLER(void);
