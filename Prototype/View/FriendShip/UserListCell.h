//
//  UserListCell.h
//  Prototype
//
//  Created by Adrian Lee on 5/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ImageV.h"
#import "Util.h"

const static CGFloat USER_LIST_CELL_HEIGTH = 70.0;

@interface UserListCell : UITableViewCell <CustomXIBObject>

@property (strong, nonatomic) NSNumber *userID;

@property (retain, nonatomic) IBOutlet ImageV *image;
@property (retain, nonatomic) IBOutlet UILabel *name;
@property (retain, nonatomic) IBOutlet UILabel *desc;

@end
