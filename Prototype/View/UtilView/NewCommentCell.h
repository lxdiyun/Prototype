//
//  NewCommentCell.h
//  Prototype
//
//  Created by Adrian Lee on 1/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NewCommentCellDelegate
- (void) sendCommentWithText:(NSString *)text;
@end

@interface NewCommentCell : UITableViewCell
- (void) redraw;
@property (strong) UIViewController<NewCommentCellDelegate> *deletegate;
@end

