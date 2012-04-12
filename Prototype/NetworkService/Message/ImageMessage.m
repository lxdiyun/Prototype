//
//  ImgMessage.m
//  Prototype
//
//  Created by Adrian Lee on 1/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ImageMessage.h"

#import "Message.h"
#import "Util.h"


@implementation ImageMessage

#pragma mark - life circle

# pragma mark - request image

+ (void) requestImageWithID:(NSNumber *)ID andHandler:(SEL)handler andTarget:(id)target;
{
	// bind handler
	[ImageMessage bindNumberID:ID withHandler:handler andTarget:target];	

	// then send message
	NSMutableDictionary *request = [[NSMutableDictionary alloc] init];

	[request setValue:@"img.get" forKey:@"method"];
	[request setValue:ID  forKey:@"params"];
	
	if (NO == [ImageMessage isUpdatingObjectNumberID:ID])
	{
		[ImageMessage markUpdatingNumberID:ID];
		[ImageMessage sendObjectRequest:request];
	}

	[request release];
}

+ (void) requestImageWithNumberIDArray:(NSArray *)numberIDArray
{
	// no handler just send the message
	NSMutableDictionary *request = [[NSMutableDictionary alloc] init];

	[request setValue:@"img.get" forKey:@"method"];
	[request setValue:numberIDArray  forKey:@"params"];

	[ImageMessage sendObjectArrayRequest:request];

	[request release];
}

@end
