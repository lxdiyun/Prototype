//
//  ProfileMamanger.h
//  Prototype
//
//  Created by Adrian Lee on 1/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ObjectManager.h"

@interface ProfileMamanger : ObjectManager
+ (void) requestUserProfileWithNumberID:(NSNumber *)ID andHandler:(SEL)handler andTarget:(id)target;
+ (void) requestUserProfileWithNumberIDArray:(NSArray *)numberIDArray;
@end
