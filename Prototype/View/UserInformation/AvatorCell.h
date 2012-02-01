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

@property (strong, nonatomic) ImageV *avatorImageV;
@property (strong, nonatomic) UIProgressView *progressBar;

- (void) redraw;
- (void) showProgressBar;
- (void) hideProgressBar;

@end
