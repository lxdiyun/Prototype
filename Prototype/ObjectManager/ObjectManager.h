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
@property (strong) NSMutableDictionary *responderArrayDict;
@property (strong) NSMutableDictionary *updatingDict;
+ (id) getInstnace;
// get object
+ (NSDictionary *) getObjectWithStringID:(NSString *)ID;
+ (NSDictionary *) getObjectWithNumberID:(NSNumber *)ID;
// request object
// bind object handler
+ (void) bindStringID:(NSString *)ID withHandler:(SEL)handler andTarget:(id)target;
+ (void) bindNumberID:(NSNumber *)ID withHandler:(SEL)handler andTarget:(id)target;
// send object request
+ (void) sendObjectRequest:(NSDictionary *)request withNumberID:(NSNumber *) ID;
+ (void) sendObjectArrayRequest:(NSDictionary *)request withNumberIDArray:(NSArray *)IDArray;
// mark object updating
+ (void) markUpdatingStringID:(NSString *)ID;
+ (void) markUpdatingNumberID:(NSNumber *)ID;
+ (void) cleanUpdatingStringID:(NSString *)ID;
+ (void) cleanUpdatingNumberID:(NSNumber *)ID;
+ (void) markUpdatingNumberIDArray:(NSArray *)IDArray;
+ (BOOL) isUpdatingObjectStringID:(NSString *)ID;
+ (BOOL) isUpdatingObjectNumberID:(NSNumber *)ID;

// handler that can bew override by subclass
- (void) checkAndPerformResponderWithID:(NSString *)ID;
- (void) checkAndPerformResponderWithStringIDArray:(NSArray *)IDArray;
@end
