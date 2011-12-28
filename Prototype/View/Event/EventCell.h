//
//  EventCell.h
//  Prototype
//
//  Created by Adrian Lee on 12/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventCell : UITableViewCell

@property (retain,nonatomic) NSDictionary *eventDict;
- (void) redraw;
@end
