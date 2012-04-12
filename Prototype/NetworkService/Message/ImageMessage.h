//
//  ImgMessage.h
//  Prototype
//
//  Created by Adrian Lee on 1/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ObjectManager.h"

@interface ImageMessage : ObjectManager
+ (void) requestImageWithID:(NSNumber *)ID andHandler:(SEL)handler andTarget:(id)target;
+ (void) requestImageWithNumberIDArray:(NSArray *)numberIDArray;
@end
