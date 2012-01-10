//
//  Created by Adrian Lee on 01/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum MESSAGE_TYPE_ENUM
{
	REQUEST_NEWER = 0x0,
	REQUEST_OLDER = 0x1,
	MAX_MESSAGE = 0x2
} MESSAGE_TYPE;

@interface ListObjectManager : NSObject
@property (strong) NSMutableDictionary *objectDict;
@property (retain) NSMutableDictionary *objectKeyArrayDict;
@property (retain) NSDictionary *lastUpdatedDateDict;
// object in list
- (id) getObject:(NSString *)objectID inList:(NSString *)listID;
// updating flag
- (BOOL) isUpatringWithType:(MESSAGE_TYPE)type withListID:(NSString *)ID;
- (BOOL) requestUpdateWith:(MESSAGE_TYPE)type withID:(NSString *)ID;
// bind and request message
- (void) bindMessageType:(MESSAGE_TYPE)type 
		  withListID:(NSString *)ID 
	     withHandler:(SEL)handler 
	       andTarget:(id)target;
- (void) bindMessageID:(NSString *)messageID 
	    withListID:(uint32_t)listID 
	      withType:(MESSAGE_TYPE)type;
// message handler
- (void) messageHandler:(id)dict withListID:(NSString *)ID;
// build message request
- (void ) setParms:(NSMutableDictionary*)params 
	withCursor:(int32_t)cursor 
	     count:(uint32_t)count 
	   forward:(BOOL)forward;
// message key
- (uint32_t) getNewestKeyWithID:(NSString *)ID;
- (uint32_t) getOldestKeyWithID:(NSString *)ID;
@end
