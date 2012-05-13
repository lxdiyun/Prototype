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

@interface ImageV () <SDWebImageManagerDelegate>
{
	NSDictionary *_pic;
	NSNumber *_picID;
	UIActivityIndicatorView *_indicator;
}

@property (strong, nonatomic) NSDictionary *pic;
@property (strong) UIActivityIndicatorView *indicator;

@end

@implementation ImageV

#pragma mark - synthesize
@synthesize pic = _pic;
@synthesize picID = _picID;
@synthesize indicator = _indicator;

#pragma mark - life cicle

- (id) initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	
	if (nil != self)
	{
		self.clipsToBounds = YES;
	}
	
	return self;
}

- (void) dealloc
{
	self.pic = nil;
	self.picID = nil;
	
	[super dealloc];
}

#pragma mark - picture infomation

- (void) setPic:(NSDictionary *)pic
{
	@autoreleasepool 
	{
		if (CHECK_EQUAL(_pic ,pic))
		{
			return;
		}
		
		[_pic release];
		
		_pic = [pic retain];
		
		NSString *baseUrl = [self.pic valueForKey:@"base_url"];
		NSMutableString *imageUrlString = nil;
		NSMutableString *preImageUrlString = nil;
		
		if (nil != baseUrl)
		{
			NSString *ID = [self.pic valueForKey:@"id"];
			NSString *salt = [self.pic valueForKey:@"salt"];
			NSString *type = [self.pic valueForKey:@"type"];
			uint32_t real_size = lrintf(self.frame.size.height*SCALE());
			uint32_t cached_size = [[ImageManager getImageSizeWithNumberID:self.picID] intValue];
			imageUrlString = [[NSMutableString alloc] init];
			
			if (cached_size > real_size)
			{
				// cached size bigger than real size
				NSString *size = [[NSString alloc] initWithFormat:@"%d", cached_size];
				[imageUrlString appendFormat:@"%@%@/%@_%@.%@", baseUrl, size, ID, salt, type];
				[size release];
			}
			else 
			{
				// cached size smaller than realsize or not cached
				NSString *size = nil;
				if (cached_size > 0)
				{
					preImageUrlString = [[NSMutableString alloc] init];
					size = [[NSString alloc] initWithFormat:@"%d", cached_size];
					[preImageUrlString appendFormat:@"%@%@/%@_%@.%@", baseUrl, size, ID, salt, type];
					[size release];
				}
				
				size = [[NSString alloc] initWithFormat:@"%d", real_size]; 
				[imageUrlString appendFormat:@"%@%@/%@_%@.%@", baseUrl, size, ID, salt, type];
				[size release];
				
				[ImageManager setImageSize:[NSNumber numberWithUnsignedInt:real_size] withNumberID:self.picID];
				
				[self startIndicator];
			} 
		}
		
		if ((nil == preImageUrlString) && (nil == imageUrlString))
		{
			[self setImage: nil];
		}
		
		// set the image to the allready cached image
		if (nil != preImageUrlString)
		{
			NSURL *imageUrl =  [[NSURL alloc] initWithString:preImageUrlString];
			[self setImageWithURL:imageUrl];
			
			[preImageUrlString release];
			[imageUrl release];
		}

		if (nil != imageUrlString) 
		{
			NSURL *imageUrl = [[NSURL alloc] initWithString:imageUrlString];
			
			[self setImageWithURL:imageUrl placeholderImage:self.image];
			
			[imageUrl release];
			[imageUrlString release];
		}
	}
}

- (void) requsetPic
{
	if (CHECK_NUMBER(self.picID))
	{
		NSDictionary *picDict = [ImageManager getObjectWithNumberID:self.picID];
		
		if (nil != picDict)
		{
			self.pic = picDict;
		}
		else
		{
			[ImageManager requestObjectWithNumberID:self.picID andHandler:@selector(requsetPic) andTarget:self];
		}
	}
}

- (void) setPicID:(NSNumber *)picID
{
	if (CHECK_EQUAL(_picID ,picID))
	{
		return;
	}
	
	[_picID release];
	
	_picID = [picID retain];
	
	[self cancelCurrentImageLoad];
	self.pic = nil;
	self.image = nil;
	
	if (nil != _picID)
	{
		[self requsetPic];
	}
}

#pragma mark - SDWebImageManagerDelegate

- (void) webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image
{
	[super webImageManager:imageManager didFinishWithImage:image];
	
	[self stopIndicator];
}

#pragma mark - indicator
- (void) startIndicator
{
	if (nil == self.indicator)
	{
		UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] init];
		[self addSubview:indicator];
		[indicator setHidden:YES];
		
		self.indicator = indicator;
		
		[indicator release];
	}
	
	if ([self.indicator isHidden])
	{
		CGPoint center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
		self.indicator.center = center;
		[self.indicator startAnimating];
		[self.indicator setHidden:NO];
	}
}

- (void) stopIndicator
{
	[self.indicator stopAnimating];
	[self.indicator setHidden:YES];
}

@end
