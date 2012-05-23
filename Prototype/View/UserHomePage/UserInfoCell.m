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
@synthesize background;

#pragma mark - custom xib object

DEFINE_CUSTOM_XIB(UserInfoCell);

#pragma mark - GUI

- (void) updateGUI
{
	[super updateGUI];
	
	if (CHECK_EQUAL(GET_USER_ID(), [self.user valueForKey:@"id"]))
	{
		self.chat.hidden = YES;
	}
	else 
	{
		self.chat.hidden = NO;
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
	[background release];
	[super dealloc];
}

@end
