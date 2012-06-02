//
//  Seperator.m
//  Prototype
//
//  Created by Adrian Lee on 6/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Seperator.h"

@implementation Seperator

#pragma mark - CustomXIBObject

DEFINE_CUSTOM_XIB(Seperator, 0);

- (void) resetupXIB:(id)xibInstance
{
	[xibInstance initGUI];
}

- (void) initGUI
{
	UIView* background = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
	background.backgroundColor = [UIColor whiteColor];
	self.backgroundView = background;
}

@end
