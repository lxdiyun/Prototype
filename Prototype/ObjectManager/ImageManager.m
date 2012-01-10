//
//  Created by Adrian Lee on 1/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ImageManager.h"

#import "Message.h"
#import "Util.h"

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

# pragma mark - request image

+ (void) requestImageWithNumberID:(NSNumber *)ID andHandler:(SEL)handler andTarget:(id)target;
{
	if (nil != ID)
	{
		// bind handler
		[ImageManager bindNumberID:ID withHandler:handler andTarget:target];	
		
		// then send message
		NSMutableDictionary *request = [[NSMutableDictionary alloc] init];
		
		[request setValue:@"img.get" forKey:@"method"];
		
		[self sendObjectRequest:request withNumberID:ID];
		
		[request release];
	}
}

+ (void) requestImageWithNumberIDArray:(NSArray *)numberIDArray
{	
	// no handler just send the message
	NSMutableDictionary *request = [[NSMutableDictionary alloc] init];
	
	[request setValue:@"img.get" forKey:@"method"];
	
	[self sendObjectArrayRequest:request withNumberIDArray:numberIDArray];
	
	[request release];
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

@end
