//
//  Created by Adrian Lee on 1/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ObjectManager.h"

@interface ImageManager : ObjectManager
+ (CGSize) getCachedImageSizeWithNumberID:(NSNumber *)ID;
+ (void) setCachedImageSize:(CGSize)size withNumberID:(NSNumber *)ID;
+ (NSInteger) createImage:(UIImage *)image withHandler:(SEL)handler andTarget:(id)target;
+ (void) saveImageCache:(UIImage *)image with:(NSDictionary *)imageObject;
@end
