//
//  ListCell.m
//  Prototype
//
//  Created by Adrian Lee on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ListCell.h"

#import "Util.h"

@implementation ListCell
@synthesize image;
@synthesize name;
@synthesize desc;

#pragma mark - custom xib object

DEFINE_CUSTOM_XIB(ListCell, 0);

- (void) resetupXIB:(ListCell *)xibinstance
{
	[xibinstance initGUI];
}

#pragma mark - life circle

- (void) dealloc 
{
	[image release];
	[name release];
	[desc release];
	[super dealloc];
}

#pragma mark - GUI

- (void) initGUI
{
	@autoreleasepool 
	{
		UIView* background = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
		CELL_BORDER(background.layer);
		self.backgroundView = background;

		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
}

@end
