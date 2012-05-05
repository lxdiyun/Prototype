//
//  TriangleView.m
//  Prototype
//
//  Created by Adrian Lee on 1/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TriangleView.h"

#import "Util.h"

@implementation TriangleView

@synthesize color = _color;

- (id)initWithFrame:(CGRect)frame andColor:(UIColor *)color
{
    self = [super initWithFrame:frame];
    if (self) 
    {
	    self.backgroundColor = [UIColor clearColor];
	    self.color = color;
    }
    return self;
}

- (void) dealloc
{
	self.color = nil;
	
	[super dealloc];
}

- (void)drawRect:(CGRect)rect
{
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	CGContextBeginPath(ctx);
	CGContextMoveToPoint   (ctx, CGRectGetMidX(rect), CGRectGetMinY(rect));  // top mid
	CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMaxY(rect));  // bottom right
	CGContextAddLineToPoint(ctx, CGRectGetMinX(rect), CGRectGetMaxY(rect));  // bottom left
	CGContextClosePath(ctx);
	
	CGContextSetFillColorWithColor(ctx, [self.color CGColor]);
	CGContextFillPath(ctx);
}

@end
