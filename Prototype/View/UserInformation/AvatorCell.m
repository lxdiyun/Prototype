//
//  AvatorCell.m
//  Prototype
//
//  Created by Adrian Lee on 12/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AvatorCell.h"

#import "Util.h"

@interface AvatorCell () 
{
	ImageV *_avatorImageV;
	
	CGFloat _imageSize;
	CGFloat _labelWidth;
	CGFloat _labelHeight;
}

@end

@implementation AvatorCell

@synthesize avatorImageV = _avatorImageV;

- (void) calculateSize
{
	_imageSize = self.contentView.frame.size.height - 10;
}

- (void) redrawAvatorImageV
{
	if (nil != self.avatorImageV)
	{
		[self.avatorImageV removeFromSuperview];
	}
	
	self.avatorImageV = [[[ImageV alloc] 
		initWithFrame:CGRectMake(0.0, 0.0, _imageSize, _imageSize)] autorelease];
	
	self.avatorImageV.center = CGPointMake(80.0 + _imageSize / 2,
					       self.contentView.frame.size.height / 2);
	
	[self.contentView addSubview:self.avatorImageV];
}

- (void) redraw
{
	@autoreleasepool
	{
		[self calculateSize];
		[self redrawAvatorImageV];
	}
}

- (void) dealloc 
{
	[self setAvatorImageV:nil];
	[super dealloc];
}

@end
