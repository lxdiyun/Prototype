//
//  CommentCell.h
//  Prototype
//
//  Created by Adrian Lee on 1/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentCell : UITableViewCell
@property (strong,nonatomic) NSDictionary *commentDict;
+ (CGFloat) cellHeightForComment:(NSDictionary *)commentDict forCellWidth:(CGFloat)width;
@end
