//
//  MapFoodHeader.h
//  Prototype
//
//  Created by Adrian Lee on 5/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Util.h"

@interface MapFoodHeader : UIView <CustomXIBObject>

@property (strong, nonatomic) NSNumber *foodID;

@property (retain, nonatomic) IBOutlet UILabel *name;
@property (retain, nonatomic) IBOutlet UILabel *score;
@property (retain, nonatomic) IBOutlet UILabel *tag3;
@property (retain, nonatomic) IBOutlet UILabel *tag3Text;
@property (retain, nonatomic) IBOutlet UILabel *tag2;
@property (retain, nonatomic) IBOutlet UILabel *tag2Text;
@property (retain, nonatomic) IBOutlet UILabel *tag1;
@property (retain, nonatomic) IBOutlet UILabel *tag1Text;

@end
