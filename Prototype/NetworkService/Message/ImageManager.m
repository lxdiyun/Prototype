//
//  ImgMessage.m
//  Prototype
//
//  Created by Adrian Lee on 1/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ImageManager.h"

#import "Message.h"
#import "Util.h"


@implementation ImageManager

#pragma mark - singleton

DEFINE_SINGLETON(ImageManager);

# pragma mark - request image

+ (void) requestImageWithID:(NSNumber *)ID andHandler:(SEL)handler andTarget:(id)target;
{
	if (nil != ID)
	{
		// bind handler
		[ImageManager bindNumberID:ID withHandler:handler andTarget:target];	
		
		// then send message
		NSMutableDictionary *request = [[NSMutableDictionary alloc] init];
		
		[request setValue:@"img.get" forKey:@"method"];
		[request setValue:ID  forKey:@"params"];
		
		if (NO == [ImageManager isUpdatingObjectNumberID:ID])
		{
			[ImageManager markUpdatingNumberID:ID];
			[ImageManager sendObjectRequest:request];
		}
		
		[request release];
	}
}

+ (void) requestImageWithNumberIDArray:(NSArray *)numberIDArray
{
	if (nil != numberIDArray)
	{
		// no handler just send the message

		NSMutableArray *checkedArray = [[NSMutableArray alloc] init];
		
		for (NSNumber *ID in numberIDArray) 
		{
			if (NO == [ImageManager isUpdatingObjectNumberID:ID])
			{
				[checkedArray addObject:ID];
				[ImageManager markUpdatingNumberID:ID];
			}
		}

		if (0 < checkedArray.count)
		{
			NSMutableDictionary *request = [[NSMutableDictionary alloc] init];
			
			[request setValue:@"img.get" forKey:@"method"];
			[request setValue:checkedArray  forKey:@"params"];
			
			[ImageManager sendObjectArrayRequest:request];
			
			[request release];
		}
		
		[checkedArray release];
	}
}

@end
