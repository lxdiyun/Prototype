//
//  FoldHeader.m
//  Prototype
//
//  Created by Adrian Lee on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FoldHeader.h"

#import <QuartzCore/QuartzCore.h>

@interface FoldHeader ()
{
	BOOL _isFolding;
	id<FoldDelegate> _delegate;
}

@end

@implementation FoldHeader

#pragma mark - custom xib object

DEFINE_CUSTOM_XIB(FoldHeader, 0);

- (void) resetupXIB:(FoldHeader *)xibInstance
{
	[xibInstance initGUI];
}

#pragma mark - life circle

@synthesize foldButton;
@synthesize isFolding = _isFolding;
@synthesize delegate = _delegate;

- (void) dealloc
{
	[foldButton release];
	
	[super dealloc];
}

#pragma mark － GUI

- (void) initGUI
{
	self.isFolding = NO;
}

- (void) resetGUI
{
	self.isFolding = NO;
	self.foldButton.layer.transform = CATransform3DIdentity;
}

#pragma mark - action

- (IBAction) tap:(id)sender 
{
	if (self.isFolding)
	{
		self.foldButton.layer.transform = CATransform3DIdentity;
		self.isFolding = NO;
	}
	else 
	{
		self.foldButton.layer.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 1.0f, 0.0f, 0.0f);
		self.isFolding = YES;
	}
	
	[self.delegate fold:self];
}

@end
