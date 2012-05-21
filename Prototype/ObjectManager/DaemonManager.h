//
//  DaemonManager.h
//  Prototype
//
//  Created by Adrian Lee on 5/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DaemonManager : NSObject

+ (void) registerDaemon:(NSString *)method with:(SEL)handler and:(id)target;

@end
