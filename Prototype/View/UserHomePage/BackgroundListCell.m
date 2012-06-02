//
//  BackgroundListCell.m
//  Prototype
//
//  Created by Adrian Lee on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BackgroundListCell.h"

@interface BackgroundListCell ()
{
	ImageV *_image;
}

@end

@implementation BackgroundListCell
@synthesize image = _image;

#pragma mark - custom xib object

DEFINE_CUSTOM_XIB(BackgroundListCell, 0);

- (void) resetupXIB:(BackgroundListCell *)xibinstance
{
	[xibinstance initGUI];
}

#pragma mark - life circle

- (void) dealloc 
{
	self.image = nil;

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
		
		if (nil == self.image)
		{
			CGRect frame = CGRectMake(0, 
						  0, 
						  self.contentView.frame.size.width, 
						  self.contentView.frame.size.height - 1);
			
			self.image = [[[ImageV alloc] initWithFrame:frame] autorelease];
			
			[self.contentView addSubview:self.image];
		}
	}
}

@end
