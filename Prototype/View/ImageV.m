//
//  ImageV.m
//  Prototype
//
//  Created by Adrian Lee on 12/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ImageV.h"

#import "Util.h"
#import "ImageManager.h"

@interface ImageV ()
{
	NSDictionary *_picDict;
	NSNumber *_picID;
}

@property (strong, nonatomic) NSDictionary *picDict;

@end

@implementation ImageV

#pragma mark - synthesize
@synthesize picDict = _picDict;
@synthesize picID = _picID;

- (void) setPicDict:(NSDictionary *)picDict
{
	@autoreleasepool 
	{
		if (_picDict == picDict)
		{
			return;
		}
		
		[_picDict release];
		
		_picDict = [picDict retain];
		
		NSString *baseUrl = [self.picDict valueForKey:@"base_url"];
		NSMutableString *imageUrlString = nil;
		
		if (nil != baseUrl)
		{
			NSString *size = [[NSString alloc] initWithFormat:@"%d", lrintf(self.frame.size.height*GET_SCALE())];
			NSString *ID = [self.picDict valueForKey:@"id"];
			NSString *salt = [self.picDict valueForKey:@"salt"];
			NSString *type = [self.picDict valueForKey:@"type"];
			
			imageUrlString = [[NSMutableString alloc] init];
			[imageUrlString appendFormat:@"%@%@/%@_%@.%@", baseUrl, size, ID, salt, type];
			
			[size release];
		}

		if (nil != imageUrlString) 
		{
			NSURL *imageUrl = [[NSURL alloc] initWithString:imageUrlString];
			
			[self setImageWithURL:imageUrl];
			
			[imageUrl release];
			[imageUrlString release];
		}
		else
		{
			[self setImage: nil];
		}
	}
	
}

- (void) requsetPic
{
	if (nil != self.picID)
	{

		
		NSDictionary *picDict = [ImageManager getObjectWithNumberID:self.picID];
		
		if (nil != picDict)
		{
			self.picDict = picDict;
		}
		else
		{
			[ImageManager requestImageWithID:self.picID andHandler:@selector(requsetPic) andTarget:self];
		}
	}
}

- (void) setPicID:(NSNumber *)picID
{
	if (_picID == picID)
	{
		return;
	}
	
	[_picID release];
	
	_picID = [picID retain];
	
	[self cancelCurrentImageLoad];
	self.picDict = nil;
	
	[self requsetPic];
}


- (void) dealloc
{
	self.picDict = nil;
	self.picID = nil;
	
	[super dealloc];
}

@end
