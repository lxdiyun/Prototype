//
//  NewFoodView.h
//  Prototype
//
//  Created by Adrian Lee on 1/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CreateFoodTask.h"


@interface CreateFoodPage : UITableViewController 

- (void) resetImage:(UIImage *)image;

@property (strong, nonatomic) CreateFoodTask *task;
@end
