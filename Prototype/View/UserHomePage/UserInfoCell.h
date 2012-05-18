//
//  UserInfoCell.h
//  Prototype
//
//  Created by Adrian Lee on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "InfoCell.h"

@protocol UserInfoCellDelegate <NSObject>

- (void) startChat;

@end

@interface UserInfoCell : InfoCell

- (IBAction) chat:(id)sender;

@property (retain, nonatomic) IBOutlet UIButton *chat;
@property (assign, nonatomic) id<ShowVCDelegate, UserInfoCellDelegate> delegate;


@end
