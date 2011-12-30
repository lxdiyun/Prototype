//
//  EventMessage.h
//  Prototype
//
//  Created by Adrian Lee on 12/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EventMessage : NSObject
+ (void) requestNewerCount:(uint32_t)count WithHandler:(SEL)handler andTarget:(id)target;
+ (void) requestMoreCount:(uint32_t)count WithHandler:(SEL)handler andTarget:(id)target;
+ (NSArray*) eventArray;
+ (BOOL) isUpdating;
+ (NSDate *) lastUpdatedDate;
@end
