//
//  CommentMessage.h
//  Prototype
//
//  Created by Adrian Lee on 12/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EventMessage : NSObject
+ (void) requestNewerCount:(uint32_t)count withHandler:(SEL)handler andTarget:(id)target;
+ (void) requestOlderCount:(uint32_t)count withHandler:(SEL)handler andTarget:(id)target;
+ (NSArray *) eventArray;
+ (BOOL) isNewerUpdating;
+ (NSDate *) lastUpdatedDate;
@end
