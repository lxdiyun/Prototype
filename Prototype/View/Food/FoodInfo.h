//
//  TagCell.h
//  Prototype
//
//  Created by Adrian Lee on 1/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ImageV.h"

@protocol FoodInfoDelegate

- (void) showVC:(UIViewController *)VC;

@end

@interface FoodInfo : UIViewController

@property (retain, nonatomic) NSDictionary *food;
@property (assign) id<FoodInfoDelegate> delegate;

@property (retain, nonatomic) IBOutlet UIView *buttons;
@property (retain, nonatomic) IBOutlet UILabel *username;
@property (retain, nonatomic) IBOutlet ImageV *avatar;
@property (retain, nonatomic) IBOutlet UILabel *date;
@property (retain, nonatomic) IBOutlet UIButton *target;
@property (retain, nonatomic) IBOutlet UIButton *ate;
@property (retain, nonatomic) IBOutlet UIButton *location;
@property (retain, nonatomic) IBOutlet ImageV *image;
@property (retain, nonatomic) IBOutlet UILabel *tag1Text;
@property (retain, nonatomic) IBOutlet UILabel *tag1;
@property (retain, nonatomic) IBOutlet UILabel *tag2Text;
@property (retain, nonatomic) IBOutlet UILabel *tag2;
@property (retain, nonatomic) IBOutlet UILabel *tag3Text;
@property (retain, nonatomic) IBOutlet UILabel *tag3;
@property (retain, nonatomic) IBOutlet UILabel *score;
- (IBAction)showInMap:(id)sender;

@end
