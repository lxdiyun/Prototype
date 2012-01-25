//
//  CreateFoodHeader.m
//  Prototype
//
//  Created by Adrian Lee on 1/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CreateFoodImage.h"

#import "Util.h"
#import "Message.h"

const static CGFloat PROGRESS_VIEW_HEIGHT = 44.0;
const static CGFloat PADING1 = 10.0; // padding between element horizontal and from border

@interface CreateFoodImage () 
{
	ImageV *_selectedImage;
	UIProgressView *_progressView;
	NSString *_uploadFileID;
}

@property (strong, nonatomic) UIProgressView *progressView;
@end

@implementation CreateFoodImage

@synthesize selectedImage = _selectedImage;
@synthesize progressView = _progressView;
@synthesize uploadFileID = _uploadFileID;

#pragma mark - lifecircle

- (void) dealloc
{
	self.selectedImage = nil;
	self.progressView = nil;
	self.uploadFileID = nil;
	
	[super dealloc];
}

#pragma mark - UI

- (void) redrawImage
{
	if (nil != self.selectedImage)
	{
		[self.selectedImage removeFromSuperview];
	}
	
	ImageV *temp = [[ImageV alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.width)];
	
	self.selectedImage = temp;
	
	[temp release];
	
	[self addSubview:self.selectedImage];
}

- (void) redrawProgressBar
{
	if (nil != self.progressView)
	{
		[self.progressView removeFromSuperview];
	}
	
	UIProgressView *temp = [[UIProgressView alloc] initWithFrame:CGRectMake(0.0, 
										0.0, 
										self.frame.size.width - PADING1 * PROPORTION(), 
										PROGRESS_VIEW_HEIGHT * PROPORTION())];
	temp.center = self.center;
	temp.progress = 0.0;
	self.progressView = temp;

	[temp release];
	
	[self addSubview:self.progressView];
}

- (void) redraw
{
	@autoreleasepool 
	{
		[self redrawProgressBar];
		[self redrawImage];
	}
}

#pragma mark - interface

- (void) resetProgress
{
	if ((nil != self.uploadFileID) && (nil != self.progressView))
	{
		BIND_PROGRESS_VIEW_WITH_FILE_ID(self.progressView, self.uploadFileID);
	}
}

@end
