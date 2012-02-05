//
//  DetailCell.h
//  Prototype
//
//  Created by Adrian Lee on 2/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailCell : UITableViewCell
@property (strong,nonatomic) NSDictionary *conversationDict;
+ (CGFloat) cellHeightForConversation:(NSDictionary *)commentDict forCellWidth:(CGFloat)width;
@end
