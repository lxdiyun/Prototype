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

#pragma mark - class interface
+ (void) updateProfile:(NSDictionary *)params 
	   withHandler:(SEL)handler 
	     andTarget:target
{
	[[self getInstnace] setUpdateParams:params];
	
	[self updateObjectWithhandler:handler andTarget:target];
}

#pragma mark - message

#pragma mark - overwrite super class method

#pragma mark - get method handler overwrite

- (void) checkAndPerformResponderWithID:(NSString *)ID
{
	@autoreleasepool 
	{
		NSNumber *avatarID = [[self.objectDict valueForKey:ID] valueForKey:@"avatar"];
		
		if (CHECK_NUMBER(avatarID))
		{
			if (nil == [ImageManager getObjectWithNumberID:avatarID])
			{
				[ImageManager requestObjectWithNumberID:avatarID andHandler:nil andTarget:nil];
			}
		}
		else
		{
			LOG(@"Error can't get avator ID for user: %@", ID);
		}
		
		[super checkAndPerformResponderWithID:ID];
	}
}

- (void) checkAndPerformResponderWithStringIDArray:(NSArray *)IDArray
{
	@autoreleasepool 
	{
		NSMutableSet *newPicSet = [[[NSMutableSet alloc] init] autorelease];

		for (NSString *ID in IDArray)
		{
			NSNumber *avatarID = [[self.objectDict valueForKey:ID] valueForKey:@"avatar"];
			
			if (CHECK_NUMBER(avatarID))
			{
				if (nil == [ImageManager getObjectWithNumberID:avatarID])
				{
					[newPicSet addObject:avatarID];
				}
			}
			else
			{
				LOG(@"Error can't get avator ID for user: %@", ID);
			}
		}
		
		// cache avator info
		[ImageManager requestObjectWithNumberIDArray:[newPicSet allObjects]];
		
		[super checkAndPerformResponderWithStringIDArray:IDArray];
	}
}

#pragma mark - overwrite get method
- (NSString *) getMethod
{
	return @"user.get";
}

#pragma mark - overwrite update method

- (NSString *) updateMethod
{
	return @"user.update";
}

@end
