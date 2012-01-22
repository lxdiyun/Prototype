//
//  CreateFoodHeader.m
//  Prototype
//
//  Created by Adrian Lee on 1/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CreateFoodImage.h"

#import "Util.h"

@interface CreateFoodImage () 
{
	
	ImageV *_selectedImage;
}

@end

@implementation CreateFoodImage

@synthesize selectedImage = _selectedImage;

#pragma mark - lifecircle

- (void) dealloc
{
	self.selectedImage = nil;
	
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

- (void) redrawButton
{
	
}

- (void) redraw
{
	@autoreleasepool 
	{
		[self redrawImage];
		[self redrawButton];
	}
}

@end
