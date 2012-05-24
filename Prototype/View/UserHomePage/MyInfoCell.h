//
//  MyInfo.h
//  Prototype
//
//  Created by Adrian Lee on 5/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InfoCell.h"

@protocol SelectBackgroundDelegate <NSObject>

- (void) selectBackground;

@end

@interface MyInfoCell : InfoCell

- (IBAction) selectBackground:(id)sender;

@property (assign, nonatomic) id<ShowVCDelegate, SelectBackgroundDelegate> delegate;

@end
