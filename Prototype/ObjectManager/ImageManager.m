//
//  Created by Adrian Lee on 1/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ImageManager.h"

#import "Message.h"
#import "Util.h"
#import "SDImageCache.h"

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
#pragma mark - create image

+ (NSInteger) createImage:(UIImage *)image withHandler:(SEL)handler andTarget:(id)target
{
	@autoreleasepool 
	{
		NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
		
		NSData *imageData = UIImageJPEGRepresentation(image, (CGFloat)0.8);
		
		[params setValue:@"new_image" forKey:@"file_name"];
		[params setValue:[NSNumber numberWithUnsignedInteger:imageData.length] 
			  forKey:@"file_size"];
		
		[[self getInstnace ] setCreateParams: params];
		
		NSInteger messageID = [self createObjectWithHandler:handler andTarget:target];
		UPLOAD_FILE(imageData, messageID);
		
		return messageID;
	}
}

#pragma mark - cache

+ (CGSize) getCachedImageSizeWithNumberID:(NSNumber *)ID
{
	@autoreleasepool 
	{
		NSString *sizeString = [[[self getInstnace] imageSizeDict] valueForKey:[ID stringValue]];
		return CGSizeFromString(sizeString);
	}
}

+ (void) setCachedImageSize:(CGSize)size withNumberID:(NSNumber *)ID
{
	@autoreleasepool 
	{
		NSString *sizeString = NSStringFromCGSize(size);
		[[[self getInstnace] imageSizeDict] setValue:sizeString  forKey:[ID stringValue]];
	}
}


+ (void) saveImageCache:(UIImage *)image with:(NSDictionary *)imageObject
{
	NSString *baseUrl = [imageObject valueForKey:@"base_url"];
	NSNumber *ID = [imageObject valueForKey:@"id"];
	NSString *salt = [imageObject valueForKey:@"salt"];
	NSString *type = [imageObject valueForKey:@"type"];
	
	
	if (nil != baseUrl && nil != ID)
	{
		@autoreleasepool 
		{
			NSString *size = [[[NSString alloc] initWithFormat:@"%d!%d", 
					  lrintf(image.size.width), 
					  lrintf(image.size.height)] 
					  autorelease];
			NSString *imageUrlString = [[[NSString alloc] initWithFormat:@"%@%@/%@_%@.%@", 
						    baseUrl, size, ID, salt, type] 
						    autorelease];
			
			[[SDImageCache sharedImageCache] storeImage:image forKey:imageUrlString];
			
			[self setObject:imageObject withNumberID:ID];
			
			[self setCachedImageSize:image.size withNumberID:ID];
		}
	
	}
}

#pragma mark - overwrite super class method

#pragma mark - overwrite save and restore

+ (void) saveTo:(NSMutableDictionary *)dict
{
	[super saveTo:dict];
	
	NSMutableString *key = [[NSMutableString alloc] initWithString:[self description]];
	[key appendString:@"Image_Size"];
	
	[dict setObject:[[self getInstnace] imageSizeDict] 
		 forKey:key];
	
	[key release];
}

+ (void) restoreFrom:(NSMutableDictionary *)dict
{
	@autoreleasepool 
	{
		[super restoreFrom:dict];
		
		NSMutableString *key = [[NSMutableString alloc] initWithString:[self description]];
		[key appendString:@"Image_Size"];
		
		NSMutableDictionary *imageSizeDict = [dict objectForKey:key];
		
		if (nil != imageSizeDict)
		{
			[[self getInstnace] setImageSizeDict:imageSizeDict];
		}
		
		[key release];
	}
}

+ (void) reset
{
	[super reset];
	
	[[[self getInstnace] imageSizeDict] removeAllObjects];
}

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
