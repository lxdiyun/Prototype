//
//  MyInfo.h
//  Prototype
//
//  Created by Adrian Lee on 5/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InfoCell.h"

@protocol MyInfoDelegate <NSObject>

- (void) selectBackground;
- (void) selectAvatar;

@end

@interface MyInfoCell : InfoCell

- (IBAction) selectBackground:(id)sender;

@property (assign, nonatomic) id<ShowVCDelegate, MyInfoDelegate> delegate;

@end
