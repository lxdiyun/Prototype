//
//  AvatorCell.h
//  Prototype
//
//  Created by Adrian Lee on 12/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ImageV.h"

@interface AvatorCell : UITableViewCell

@property (retain, nonatomic)  ImageV *avatorImageV;
- (void) redraw;
@end
