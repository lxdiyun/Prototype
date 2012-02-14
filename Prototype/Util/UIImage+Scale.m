//
//  UIImage+.m
//  Prototype
//
//  Created by Adrian Lee on 1/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIImage+Scale.h"

#import "Util.h"

#include <math.h>

static inline double radians (double degrees) {return degrees * M_PI / 180;}

@implementation UIImage (Scale)

- (UIImage *) reduceToResolution:(CGFloat)resolution 
{
	CGFloat width = self.size.width;
	CGFloat height = self.size.height;
	CGRect bounds = CGRectMake(0, 0, width, height);
	
	LOG(@"s = %f %f, t = %f", width, height, resolution);
	
	//if already at the minimum resolution, return the orginal image, otherwise scale
	if (width <= resolution && height <= resolution) 
	{
		return self;
	} 
	else 
	{
		CGFloat ratio = width / height;
		
		if (ratio > 1) 
		{
			bounds.size.width = resolution;
			bounds.size.height = bounds.size.width / ratio;
		} else 
		{
			bounds.size.height = resolution;
			bounds.size.width = bounds.size.height * ratio;
		}
	}
	
	LOG(@"bouds W = %f H = %f", bounds.size.width, bounds.size.height);
	
	UIGraphicsBeginImageContext(bounds.size);
	[self drawInRect:CGRectMake(0.0, 0.0, bounds.size.width, bounds.size.height)];
	UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return imageCopy;
}

@end
