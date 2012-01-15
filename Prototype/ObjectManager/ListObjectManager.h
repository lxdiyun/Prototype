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
@property (strong) NSMutableDictionary *objectKeyArrayDict;
@property (strong) NSDictionary *lastUpdatedDateDict;
// object in list
+ (id) getObject:(NSString *)objectID inList:(NSString *)listID;
// updating flag
+ (BOOL) isUpdatingWithType:(MESSAGE_TYPE)type withListID:(NSString *)listID;
// update date
+ (NSDate *)lastUpdatedDateForList:(NSString *)listID;
// message request - get mthod
+ (void) requestNewerWithListID:(NSString *)listID 
		       andCount:(uint32_t)count 
		    withHandler:(SEL)handler 
		      andTarget:(id)target;
+ (void) requestOlderWithListID:(NSString *)listID 
		       andCount:(uint32_t)count 
		    withHandler:(SEL)handler 
		      andTarget:(id)target;
// key array
+ (NSArray *) keyArrayForList:(NSString *)listID;

// method that must be overwrite by sub class
// request get method
- (NSString *) getMethod;
- (void) setGetMethodParams:(NSMutableDictionary *)params forList:(NSString *)listID;

// method that can be overwrite by sub class
// message handler
- (void) messageHandler:(id)dict withListID:(NSString *)ID;



@end
