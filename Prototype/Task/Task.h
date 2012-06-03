//
//  Task.h
//  Prototype
//
//  Created by Adrian Lee on 6/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Task : NSObject

- (void) start;
- (void) cancel;
- (void) checkCondition;
- (void) confirm;


- (BOOL) isAllConditionReady;
- (void) execute;

@property (strong, nonatomic) NSString *taskID;

@end
