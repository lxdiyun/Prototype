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

	[self clear];

	NSString *imageUrlString = [self.picDict valueForKey:@"size200"];

	if (nil != imageUrlString) 
	{
		NSURL *imageUrl = [[NSURL alloc] initWithString:imageUrlString];
		
		self.url = imageUrl;
		[self showLoadingWheel];
		MANAGE_OBJ(self);
		
		[imageUrl release];
	}
}

-(void) showLoadingWheel 
{
	[loadingWheel removeFromSuperview];
	self.loadingWheel = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
	loadingWheel.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
	loadingWheel.hidesWhenStopped=YES;
	[self addSubview:loadingWheel];
	[loadingWheel startAnimating];
}

- (void) dealloc
{
	self.picDict = nil;
	
	[super dealloc];
}

@end
