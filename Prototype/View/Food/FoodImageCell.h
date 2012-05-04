//
//  FoodImageCell.h
//  Prototype
//
//  Created by Adrian Lee on 12/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ImageV.h"
#import "FoodScore.h"

@interface FoodImageCell : UITableViewCell

- (void) redraw;
@property (strong, nonatomic) ImageV *foodImage;
@property (strong, nonatomic) FoodScore *score;
@end
