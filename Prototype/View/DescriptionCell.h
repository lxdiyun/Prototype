//
//  DescriptionCell.h
//  Prototype
//
//  Created by Adrian Lee on 1/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DescriptionCell : UITableViewCell
@property (strong, nonatomic) NSDictionary *objectDict;
+ (CGFloat) cellHeightForObject:(NSDictionary *)objectDict forCellWidth:(CGFloat)width;
@end
