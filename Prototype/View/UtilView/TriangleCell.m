//
//  TriangleCell.m
//  Prototype
//
//  Created by Adrian Lee on 5/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TriangleCell.h"

const CGFloat PADDING = 10.0; // padding from right
const CGFloat WIDTH = 20.0; // triangle width
const CGFloat HEIGHT =  10.0; // triangle heiht

@interface TriangleCell ()
{
	UIColor *_backColor;
	UIColor *_triangleColor;
}

@property (strong, nonatomic) UIColor *backColor;
@property (strong, nonatomic) UIColor *triangleColor;

@end

@implementation TriangleCell

@synthesize backColor = _backColor;
@synthesize triangleColor = _triangleColor;

- (id) initWithStyle:(UITableViewCellStyle)style 
     reuseIdentifier:(NSString *)reuseIdentifier
	   backColor:(UIColor *)backColor
       triangleColor:(UIColor *)triangleColor
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) 
	{
		self.backColor = backColor;
		self.triangleColor = triangleColor;
		self.selectionStyle = UITableViewCellSelectionStyleNone;
	}

	return self;
}

- (void) drawRect:(CGRect)rect
{
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextSetFillColorWithColor(ctx, [self.backColor CGColor]);
	CGContextFillRect(ctx, rect);
	
	CGPoint p1 = CGPointMake(CGRectGetMaxX(rect) - PADDING, CGRectGetMaxY(rect) - HEIGHT); // top right
	CGPoint p2 = CGPointMake(p1.x - WIDTH / 2 , p1.y + HEIGHT); // bottom mid
	CGPoint p3 = CGPointMake(p1.x - WIDTH, p1.y); // top left
	
	
	CGContextBeginPath(ctx);
	CGContextMoveToPoint   (ctx, p1.x, p1.y);
	CGContextAddLineToPoint(ctx, p2.x, p2.y);
	CGContextAddLineToPoint(ctx, p3.x, p3.y);
	CGContextClosePath(ctx);
	
	CGContextSetFillColorWithColor(ctx, [self.triangleColor CGColor]);
	CGContextFillPath(ctx);
}

@end
