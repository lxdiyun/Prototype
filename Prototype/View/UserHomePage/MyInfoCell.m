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
	id<ShowVCDelegate, SelectBackgroundDelegate> _delegate;
}

@end

@implementation MyInfoCell

@synthesize delegate = _delegate;

#pragma mark - custom xib object

DEFINE_CUSTOM_XIB(MyInfoCell);

- (IBAction) selectBackground:(id)sender 
{
	[self.delegate selectBackground];
}
@end
