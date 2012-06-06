//
//  ObjectSaver.h
//  Prototype
//
//  Created by Adrian Lee on 1/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ObjectSaver : NSObject
+ (void) saveAll;
+ (void) restoreAll;
+ (void) resetCache;
@end
