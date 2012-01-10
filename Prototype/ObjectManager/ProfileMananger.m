//
//  Created by Adrian Lee on 1/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ProfileMananger.h"

#import "Util.h"
#import "ImageManager.h"

@implementation ProfileMananger

#pragma mark - singleton
DEFINE_SINGLETON(ProfileMananger);

#pragma mark - message

+ (void) requestUserProfileWithNumberID:(NSNumber *)ID andHandler:(SEL)handler andTarget:(id)target
{
	if (nil != ID)
	{
		// bind handler
		[ProfileMananger bindNumberID:ID withHandler:handler andTarget:target];	
		
		// then send message
		NSMutableDictionary *request = [[NSMutableDictionary alloc] init];
		
		[request setValue:@"user.get" forKey:@"method"];
		
		[self sendObjectRequest:request withNumberID:ID];
		
		[request release];
	}
}

+ (void) requestUserProfileWithNumberIDArray:(NSArray *)numberIDArray
{
	if (nil != numberIDArray)
	{
		// no handler just send the message
		NSMutableDictionary *request = [[NSMutableDictionary alloc] init];
		
		[request setValue:@"user.get" forKey:@"method"];
		
		[self sendObjectArrayRequest:request withNumberIDArray:numberIDArray];
		
		[request release];
	}
}

#pragma mark - handler overwrite

- (void) cacheAvatorInfoWithUserID:(NSString *)ID
{
	NSNumber *avatarID = [[self.objectDict valueForKey:ID] valueForKey:@"avatar"];
	
	if (nil == [ImageManager getObjectWithNumberID:avatarID])
	{
		[ImageManager requestImageWithNumberID:avatarID andHandler:nil andTarget:nil];
	}
}

- (void) checkAndPerformResponderWithID:(NSString *)ID
{
	@autoreleasepool 
	{
		[super checkAndPerformResponderWithID:ID];
		
		[self cacheAvatorInfoWithUserID:ID];
	}
}

- (void) checkAndPerformResponderWithStringIDArray:(NSArray *)IDArray
{
	@autoreleasepool 
	{
		[super checkAndPerformResponderWithStringIDArray:IDArray];
		for (NSString *ID in IDArray)
		{
			[self cacheAvatorInfoWithUserID:ID];
		}
	}
}

@end
