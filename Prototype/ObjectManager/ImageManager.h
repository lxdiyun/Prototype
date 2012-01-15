//
//  Created by Adrian Lee on 1/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ObjectManager.h"

@interface ImageManager : ObjectManager
+ (NSNumber *) getImageSizeWithNumberID:(NSNumber *)ID;
+ (void) setImageSize:(NSNumber *)size withNumberID:(NSNumber *)ID;
+ (void) createImage:(UIImage *)image withHandler:(SEL)handler andTarget:(id)target;
@end
