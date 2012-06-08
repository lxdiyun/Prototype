//
//  CreateFoodTask.h
//  Prototype
//
//  Created by Adrian Lee on 6/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Task.h"

@interface CreateFoodTask : Task

- (NSInteger) picSelected:(UIImage *)pic;
- (void) etcReady:(NSDictionary *)etcParams;
- (void) etcAndPlaceReady:(NSDictionary *)etcAndPlaceParams; 
- (void) placeSelected:(NSDictionary *)placeParams;

@end
