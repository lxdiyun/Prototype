//
//  Created by Adrian Lee on 01/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum MESSAGE_TYPE_ENUM
{
	REQUEST_NEWER = 0x0,
	REQUEST_OLDER = 0x1,
	LIST_OBJECT_CREATE = 0x2,
	MAX_MESSAGE
} LIST_OBJECT_MESSAGE_TYPE;

@interface ListObjectManager : NSObject
@property (strong) NSMutableDictionary *objectDict;
@property (strong) NSMutableDictionary *objectKeyArrayDict;
@property (strong) NSDictionary *lastUpdatedDateDict;

// save and restore
+ (void) save;
+ (void) restore;

// key array
+ (NSArray *) keyArrayForList:(NSString *)listID;

// object in list
+ (id) getObject:(NSString *)objectID inList:(NSString *)listID;

// updating flag
+ (BOOL) isUpdatingWithType:(LIST_OBJECT_MESSAGE_TYPE)type withListID:(NSString *)listID;

// update date
+ (NSDate *)lastUpdatedDateForList:(NSString *)listID;

// get method
+ (void) requestNewerWithListID:(NSString *)listID 
		       andCount:(uint32_t)count 
		    withHandler:(SEL)handler 
		      andTarget:(id)target;
+ (void) requestOlderWithListID:(NSString *)listID 
		       andCount:(uint32_t)count 
		    withHandler:(SEL)handler 
		      andTarget:(id)target;
- (void) getMethodHandler:(id)result withListID:(NSString *)ID;

// create method
+ (void) requestCreateWithListID:(NSString *)listID 
		     withHandler:(SEL)handler 
		       andTarget:(id)target;
- (void) createMethodHanlder:(id)result withListID:(NSString *)ID;

// method that must be overwrite by sub class
// get method
- (NSString *) getMethod;
- (void) setGetMethodParams:(NSMutableDictionary *)params forList:(NSString *)listID;
// create method
- (NSString *) createMethod;
- (void) setCreateMethodParams:(NSMutableDictionary *)params forList:(NSString *)listID;


@end
