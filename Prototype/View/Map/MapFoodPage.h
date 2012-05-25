//
//  MapFoodPage.h
//  Prototype
//
//  Created by Adrian Lee on 5/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Util.h"
#import "ImageV.h"

@interface MapFoodPage : UIScrollView <CustomXIBObject>

@property (strong, nonatomic) NSNumber *foodID;

@property (retain, nonatomic) IBOutlet ImageV *image;
@property (retain, nonatomic) IBOutlet UILabel *desc;

@end
