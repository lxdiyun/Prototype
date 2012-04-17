//
//  FoodDescCell.h
//  Prototype
//
//  Created by Adrian Lee on 4/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FoodDescCell : UITableViewCell

@property (retain, nonatomic) NSString *description;

+ (CGFloat) cellHeightForDesc:(NSString *)description;

@end
