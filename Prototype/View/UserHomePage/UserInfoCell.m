//
//  UserInfoCell.m
//  Prototype
//
//  Created by Adrian Lee on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UserInfoCell.h"

@interface UserInfoCell ()
{
	id<ShowVCDelegate, UserInfoCellDelegate> _delegate;
}

@end

@implementation UserInfoCell

@synthesize chat;
@synthesize delegate = _delegate;

#pragma mark - custom xib object

DEFINE_CUSTOM_XIB(UserInfoCell);

#pragma mark - GUI

- (void) updateGUI
{
	[super updateGUI];
	
	if (CHECK_EQUAL(GET_USER_ID(), [self.user valueForKey:@"id"]))
	{
		self.chat.hidden = YES;
		self.background.image = [UIImage imageNamed:@"background2.png"];
	}
	else 
	{
		self.chat.hidden = NO;
		self.background.image = [UIImage imageNamed:@"background3.png"];
	}
}

#pragma mark - action

- (IBAction) chat:(id)sender 
{
	[self.delegate startChat];
}

- (void) dealloc 
{
	[chat release];
	[super dealloc];
}

@end
