//
//  BackgroundListCell.h
//  Prototype
//
//  Created by Adrian Lee on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ImageV.h"
#import "Util.h"

const static CGFloat BACKGROUND_LIST_CELL_HEIGTH = 201.0;

@interface BackgroundListCell : UITableViewCell <CustomXIBObject>

@property (retain, nonatomic) ImageV *image;

@end
