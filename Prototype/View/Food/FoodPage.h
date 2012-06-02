//
//  FoodPage.h
//  Prototype
//
//  Created by Adrian Lee on 6/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FoodToolBar.h"

@interface FoodPage : UIViewController

@property (assign, nonatomic) NSNumber *foodID;

@property (retain, nonatomic) IBOutlet FoodToolBar *toolbar;

@end
