//
//  AvatorCell.m
//  Prototype
//
//  Created by Adrian Lee on 12/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AvatorCell.h"

@interface AvatorCell () 
{
	ImageV *_avatorImageV;
	UILabel *_avatorLabel;
	
	CGFloat _imageSize;
	CGFloat _labelWidth;
	CGFloat _labelHeight;
}

@property (retain)  UILabel *avatorLabel;

@end

@implementation AvatorCell

@synthesize avatorImageV = _avatorImageV;
@synthesize avatorLabel = _avatorLabel;



- (void) calculateSize
{
	_imageSize = self.contentView.frame.size.height - 10;
	_labelWidth = 50.0;
	_labelHeight = 22.0;
}

- (void) redrawAvatorImageV
{
	if (nil != self.avatorImageV)
	{
		[self.avatorImageV removeFromSuperview];
	}
	
	self.avatorImageV = [[[ImageV alloc] 
		initWithFrame:CGRectMake(0.0, 0.0, _imageSize, _imageSize)] autorelease];
	
	self.avatorImageV.center = CGPointMake(_labelWidth + 15.0 + _imageSize/2,
					       self.contentView.frame.size.height/2);
	
	[self.contentView addSubview:self.avatorImageV];
}

- (void) redrawAvatorLabel
{
	if(nil != self.avatorLabel)
	{
		[self.avatorLabel removeFromSuperview];
	}
	CGFloat frmaeHeight  = self.contentView.frame.size.height;

	self.avatorLabel = [[[UILabel alloc] initWithFrame:CGRectMake(5.0, 
								     (frmaeHeight - _labelHeight)/2, 
								     _labelWidth, 
								     _labelHeight)] 
			    autorelease];

	self.avatorLabel.font = [UIFont boldSystemFontOfSize:18.0];
	self.avatorLabel.adjustsFontSizeToFitWidth = YES;
	self.avatorLabel.backgroundColor = [UIColor clearColor];
	self.avatorLabel.textAlignment = UITextAlignmentRight;
	self.avatorLabel.text = @"头像";
	[self.contentView addSubview:self.avatorLabel];
}

- (void) redraw
{
	@autoreleasepool
	{
		[self calculateSize];
		[self redrawAvatorLabel];
		[self redrawAvatorImageV];
	}
}

- (void)dealloc 
{
	[self setAvatorImageV:nil];
	[self setAvatorLabel:nil];
	[super dealloc];
}

@end
