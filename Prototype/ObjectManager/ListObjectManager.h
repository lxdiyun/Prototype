//
//  Created by Adrian Lee on 01/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum MESSAGE_TYPE_ENUM
{
	REQUEST_NEWEST = 0x0,
	REQUEST_NEWER = 0x1,
	REQUEST_MIDDLE= 0x2,
	REQUEST_OLDER = 0x3,
	LIST_OBJECT_CREATE = 0x4,
	LIST_OBJECT_READ = 0x5,
	LIST_OBJECT_UPDATE = 0x6,
	LIST_OBJECT_DELETE = 0x7,
	MAX_MESSAGE
} LIST_OBJECT_MESSAGE_TYPE;

@interface ListObjectManager : NSObject
@property (strong) NSMutableDictionary *objectDict;
@property (strong) NSMutableDictionary *objectKeyArrayDict;
@property (strong) NSDictionary *lastUpdatedDateDict;

// C.R.U.D
@property (strong) NSString *createMethodString;
@property (strong) NSString *getMethodString;
@property (strong) NSString *updateMethodString;
@property (strong) NSString *deleteMethodString;

// save and restore
+ (void) saveTo:(NSMutableDictionary *)dict;
+ (void) restoreFrom:(NSMutableDictionary *)dict;
+ (void) reset;

// key and cursor
- (void) updateKeyArrayForList:(NSString *)listID withResult:(NSArray *)result forward:(BOOL)forward;
+ (NSArray *) keyArrayForList:(NSString *)listID;
- (NSString *) newestKeyWithListID:(NSString *)listID;
- (NSString *) keyForObjectID:(NSString *)objectID inList:(NSString *)listID;
- (NSString *) oldestKeyWithListID:(NSString *)listID;
+ (NSString *) newestKeyForList:(NSString *)listID;
+ (NSString *) oldestKeyForList:(NSString *)listID;
- (NSNumber *) cursorForKey:(NSString *)key inList:(NSString *)listID;


// object in list
+ (id) getObject:(NSString *)objectID inList:(NSString *)listID;
+ (void) setObject:(NSDictionary *)object 
      withStringID:(NSString *)objectID 
	    inList:(NSString *)listID;

// updating flag
+ (BOOL) isUpdatingWithType:(LIST_OBJECT_MESSAGE_TYPE)type withListID:(NSString *)listID;

// update date
+ (NSDate *) lastUpdatedDateForList:(NSString *)listID;

// get method
+ (void) requestNewestWithListID:(NSString *)listID 
		       andCount:(uint32_t)count 
		    withHandler:(SEL)handler 
		      andTarget:(id)target;

+ (void) requestNewerWithListID:(NSString *)listID 
		       andCount:(uint32_t)count 
		    withHandler:(SEL)handler 
		      andTarget:(id)target;

+ (void) requestMiddle:(NSString *)objectID
	      inListID:(NSString *)listID 
	      andCount:(uint32_t)count 
	   withHandler:(SEL)handler 
	     andTarget:(id)target;

+ (void) requestOlderWithListID:(NSString *)listID 
		       andCount:(uint32_t)count 
		    withHandler:(SEL)handler 
		      andTarget:(id)target;
- (void) getNewestMethodHandler:(id)result withListID:(NSString *)listID forward:(BOOL)forward;
- (void) getMethodHandler:(id)result withListID:(NSString *)listID forward:(BOOL)forward;

- (void) configGetMethodParams:(NSMutableDictionary *)params 
		       forList:(NSString *)listID;

// create method
+ (void) requestCreateWithObject:(NSDictionary *)newobject
			  inList:(NSString *)listID 
		     withHandler:(SEL)handler 
		       andTarget:(id)target;

- (void) createMethodHandler:(id)result withListID:(NSString *)listID;

- (void) configCreateMethodParams:(NSMutableDictionary *)params 
			forObject:(NSDictionary *)object
			   inList:(NSString *)listID;

// update method
+ (void) requestUpdateWithObject:(NSDictionary *)object 
			  inList:(NSString *)listID
		     withHandler:(SEL)handler
		       andTarget:(id)target;

- (void) updateMethodHandler:(id)result withListID:(NSString *)listID;

- (void) configUpdateParams:(NSMutableDictionary *)params 
		  forObject:(NSDictionary *)object
		     inList:(NSString *)listID;

// delete method
+ (void) requestDeleteWithObject:(NSString *)objectID
			  inList:(NSString *)listID 
		     withHandler:(SEL)handler 
		       andTarget:(id)target;

- (void) deleteMethodHandler:(id)result withListID:(NSString *)listID;

- (void) configDeleteMethodParams:(NSMutableDictionary *)params 
			forObject:(NSString *)objectID
			   inList:(NSString *)listID;


@end
