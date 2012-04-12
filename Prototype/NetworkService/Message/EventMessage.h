//
//  EventMessage.h
//  Prototype
//
//  Created by Adrian Lee on 12/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ObjectManager.h"

@interface EventMessage : ObjectManager
+ (EventMessage *)getInstnace;
+ (void) requestNewerCount:(uint32_t)count withHandler:(SEL)handler andTarget:(id)target;
+ (void) requestOlderCount:(uint32_t)count withHandler:(SEL)handler andTarget:(id)target;
+ (NSArray *) eventKeyArray;
+ (BOOL) isNewerUpdating;
+ (NSDate *) lastUpdatedDate;
@end
