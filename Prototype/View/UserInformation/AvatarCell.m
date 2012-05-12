//
//  AvatorCell.m
//  Prototype
//
//  Created by Adrian Lee on 12/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AvatarCell.h"

#import "Util.h"

@interface AvatarCell () 
{
	ImageV *_avatorImageV;
	UIProgressView *_progressBar;
	
	CGFloat _imageSize;
	CGFloat _labelWidth;
	CGFloat _labelHeight;
}

@end

@implementation AvatarCell

@synthesize avatorImageV = _avatorImageV;
@synthesize progressBar = _progressBar;

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

- (void) showProgressBar
{
	@autoreleasepool 
	{
		[self hideProgressBar];
		
		CGFloat X = 80.0;
		CGFloat Y = 0.0;
		CGFloat W = self.contentView.frame.size.width - X - 10.0;
		CGFloat H = self.contentView.frame.size.height;
		
		self.progressBar = [[[UIProgressView alloc] initWithFrame:CGRectMake(X, Y, W, H)] autorelease];

		CGPoint center = self.progressBar.center;
		center.y = self.contentView.center.y;
		self.progressBar.center = center;
		
		[self.contentView addSubview:self.progressBar];
	}
}
- (void) hideProgressBar
{
	if (nil != self.progressBar)
	{
		[self.progressBar removeFromSuperview];
		self.progressBar = nil;
	}
}

- (void) dealloc 
{
	[self setAvatorImageV:nil];
	[self setProgressBar:nil];

	[super dealloc];
}

@end
