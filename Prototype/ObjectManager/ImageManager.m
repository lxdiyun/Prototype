//
//  Created by Adrian Lee on 1/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ImageManager.h"

#import "Message.h"
#import "Util.h"
#import "UIImage+Scale.h"

const static CGFloat MAX_IMAGE_WIDTH = 640.0;
const static CGFloat MAX_IMAGE_HEIGHT = 960.0;

@interface ImageManager ()
{
	NSMutableDictionary *_imageSizeDict;
}
@property (strong) NSMutableDictionary *imageSizeDict;
@end

@implementation ImageManager

@synthesize imageSizeDict = _imageSizeDict;

#pragma mark - singleton

DEFINE_SINGLETON(ImageManager);

#pragma mark - life circle

- (id) init
{
	self = [super init];
	
	if (nil != self)
	{
		// init data
		NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
		self.imageSizeDict = tempDict;
		[tempDict release];
	}
	
	return self;
	
}

- (void) dealloc
{
	self.imageSizeDict = nil;

	[super dealloc];
}

#pragma mark - image size

+ (NSNumber *) getImageSizeWithNumberID:(NSNumber *)ID
{
	@autoreleasepool 
	{
		return [[[self getInstnace] imageSizeDict] valueForKey:[ID stringValue]];
	}
}

+ (void) setImageSize:(NSNumber *)size withNumberID:(NSNumber *)ID
{
	@autoreleasepool 
	{
		[[[self getInstnace] imageSizeDict] setValue:size  forKey:[ID stringValue]];
	}
}

#pragma mark - create image

+ (void) createImage:(UIImage *)image withHandler:(SEL)handler andTarget:(id)target
{
	@autoreleasepool 
	{

		NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
		
		UIImage *resizedImage = [image reduceToSize:CGSizeMake(MAX_IMAGE_WIDTH, MAX_IMAGE_HEIGHT)];
		
		NSData *imageData = UIImageJPEGRepresentation(resizedImage, (CGFloat)0.8);
		
		[params setValue:@"new_image" forKey:@"file_name"];
		[params setValue:[NSNumber numberWithUnsignedInteger:imageData.length] 
			  forKey:@"file_size"];
		
		[[self getInstnace ] setCreateParams: params];
		
		uint32_t messageID = [self createObjectWithHandler:handler andTarget:target];
		UPLOAD_FILE(imageData, messageID);
	}
}

#pragma mark - overwrite super class method
#pragma mark - overwrite get method

- (NSString *) getMethod
{
	return @"img.get";
}

#pragma mark - overwrite create method

- (NSString *) createMethod
{
	return @"img.create";
}

- (void) setParamsForCreate:(NSMutableDictionary *)request
{
	[request setValue:self.createParams forKey:@"params"];	
}

@end
