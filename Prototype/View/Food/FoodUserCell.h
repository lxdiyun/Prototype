//
//  TagCell.h
//  Prototype
//
//  Created by Adrian Lee on 1/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ImageV.h"

@interface FoodUserCell : UIViewController

@property (retain, nonatomic) NSDictionary *food;

@property (retain, nonatomic) IBOutlet UIView *buttons;
@property (retain, nonatomic) IBOutlet UILabel *username;
@property (retain, nonatomic) IBOutlet ImageV *avatar;
@property (retain, nonatomic) IBOutlet UILabel *date;
@property (retain, nonatomic) IBOutlet UIButton *target;
@property (retain, nonatomic) IBOutlet UIButton *ate;
@property (retain, nonatomic) IBOutlet UIButton *location;


@end
