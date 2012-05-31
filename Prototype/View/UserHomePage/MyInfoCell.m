//
//  MyInfo.m
//  Prototype
//
//  Created by Adrian Lee on 5/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MyInfoCell.h"

@interface MyInfoCell ()
{
	id<ShowVCDelegate, MyInfoDelegate> _delegate;
}

@end

@implementation MyInfoCell

@synthesize delegate = _delegate;

#pragma mark - custom xib object

DEFINE_CUSTOM_XIB(MyInfoCell);

- (void) resetupXIB:xibInstance
{
	[xibInstance initGUI];
}

#pragma mark - life circle

#pragma mark - GUI

- (void) initGUI
{
	[super initGUI];

	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self 
									      action:@selector(selectAvatar)];
	
	[self.avatar addGestureRecognizer:tap];
	self.avatar.userInteractionEnabled = YES;
	
	[tap release];
}

#pragma mark - actioni

- (IBAction) selectBackground:(id)sender 
{
	[self.delegate selectBackground];
}

- (void) selectAvatar
{
	[self.delegate selectAvatar];
}

@end
