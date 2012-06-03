//
//  TaskManager.h
//  Prototype
//
//  Created by Adrian Lee on 6/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Task.h"

@interface TaskManager : NSObject

+ (void) registTask:(Task *)task;
+ (void) deregistTask:(Task *)task;


@end
