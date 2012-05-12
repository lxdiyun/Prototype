//
//  CommentCell.h
//  Prototype
//
//  Created by Adrian Lee on 1/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Util.h"

@interface CommentCell : UITableViewCell

+ (CGFloat) cellHeightForComment:(NSDictionary *)commentDict forCellWidth:(CGFloat)width;

@property (strong, nonatomic) NSDictionary *commentDict;
@property (assign, nonatomic) id<ShowVCDelegate> delegate;


@end
