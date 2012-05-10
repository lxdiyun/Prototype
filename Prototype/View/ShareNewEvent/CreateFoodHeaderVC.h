//
//  CreateFoodHeaderVC.h
//  Prototype
//
//  Created by Adrian Lee on 5/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ImageV.h"

@interface CreateFoodHeaderVC : UIViewController

- (void) cleanHeader;

- (IBAction) scoreChanged:(id)sender;
- (IBAction) tapButton:(id)sender;

@property (retain, nonatomic) IBOutlet UILabel *score;
@property (retain, nonatomic) IBOutlet UIButton *special;
@property (retain, nonatomic) IBOutlet UIButton *valued;
@property (retain, nonatomic) IBOutlet UIButton *health;
@property (retain, nonatomic) IBOutlet ImageV *image;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

@end
