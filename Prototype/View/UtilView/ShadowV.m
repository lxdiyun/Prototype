//
//  ShadowV.m
//  Prototype
//
//  Created by Adrian Lee on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ShadowV.h"

#import <QuartzCore/QuartzCore.h>

@interface ShadowV ()
{
}

@end

@implementation ShadowV


- (id) initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];

	if (self) 
	{
	}
	return self;
}

- (void) drawWithTop:(UIColor *)top bottom:(UIColor *)bottom
{
	CAGradientLayer *gradient = [CAGradientLayer layer];
	CGRect frame = self.frame;
	frame.origin.x = 0;
	frame.origin.y = 0;
	
	gradient.frame = frame;
	
	gradient.colors = [NSArray arrayWithObjects: (id)top.CGColor,
			   (id)bottom.CGColor, 
			   nil];
	
	[self.layer insertSublayer:gradient atIndex:0];
}

@end
