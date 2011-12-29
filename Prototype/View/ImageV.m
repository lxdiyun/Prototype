//
//  ImageV.m
//  Prototype
//
//  Created by Adrian Lee on 12/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ImageV.h"

#import "Util.h"

@interface ImageV ()
{
	NSDictionary *_picDict;
}

@end

@implementation ImageV

#pragma mark - synthesize
@synthesize picDict = _picDict;

- (void) setPicDict:(NSDictionary *)picDict
{
	if (_picDict == picDict)
	{
		return;
	}

	[_picDict release];

	_picDict = [picDict retain];

	NSString *imageUrlString = [self.picDict valueForKey:@"size200"];

	if (nil != imageUrlString) 
	{
		NSURL *imageUrl = [[NSURL alloc] initWithString:imageUrlString];
		
		[self setImageWithURL:imageUrl];
		
		[imageUrl release];
	}
}


- (void) dealloc
{
	self.picDict = nil;
	
	[super dealloc];
}

@end
