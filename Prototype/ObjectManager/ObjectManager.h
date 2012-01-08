//
//  ObjectManager.h
//  Prototype
//
//  Created by Adrian Lee on 1/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ObjectManager : NSObject
@property (strong) NSMutableDictionary *objectDict;
@property (strong) NSMutableDictionary *updatingDict;
@property (strong) NSMutableDictionary *responderArrayDict;
+ (id) getInstnace;
// get object
+ (NSDictionary *) getObjectWithStringID:(NSString *)ID;
+ (NSDictionary *) getObjectWithNumberID:(NSNumber *)ID;
// request object
// bind object handler
+ (void) bindStringID:(NSString *)ID withHandler:(SEL)handler andTarget:(id)target;
+ (void) bindNumberID:(NSNumber *)ID withHandler:(SEL)handler andTarget:(id)target;
// send object request
+ (void) sendObjectRequest:(NSDictionary *)request;
+ (void) sendObjectArrayRequest:(NSDictionary *)request;
// mark object updating
+ (void) markUpdatingStringID:(NSString *)ID;
+ (void) markUpdatingNumberID:(NSNumber *)ID;
+ (void) markUpdatingNumberIDArray:(NSArray *)IDArray;
+ (BOOL) isUpdatingObjectStringID:(NSString *)ID;
+ (BOOL) isUpdatingObjectNumberID:(NSNumber *)ID;
@end
