//
//  PublicFoodMapListManager.m
//  Prototype
//
//  Created by Adrian Lee on 5/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PublicFoodMapListManager.h"

#import "Util.h"
#import "PlaceManager.h"

static NSString *gs_fakeListID = nil;

@implementation PublicFoodMapListManager

#pragma mark - singleton

DEFINE_SINGLETON(PublicFoodMapListManager);

#pragma mark - life circle

- (id) init
{
	self = [super init];
	
	if (nil !=self) 
	{
		@autoreleasepool 
		{
			self.getMethodString = @"foodmap.get_public_list";

			if (nil == gs_fakeListID)
			{
				gs_fakeListID = [[NSString alloc] initWithFormat:@"%d", 0x1];
			}
		}
	}
	
	return self;
}

- (void) dealloc
{
	[gs_fakeListID release];
	gs_fakeListID = nil;
	[super dealloc];
}

#pragma mark - send request message

+ (void) requestNewerCount:(uint32_t)count withHandler:(SEL)handler andTarget:(id)target
{
	return [self requestNewerWithListID:gs_fakeListID 
				   andCount:count 
				withHandler:handler 
				  andTarget:target];
}
+ (void) requestOlderCount:(uint32_t)count withHandler:(SEL)handler andTarget:(id)target
{
	return [self requestOlderWithListID:gs_fakeListID 
				   andCount:count 
				withHandler:handler 
				  andTarget:target];
}

#pragma mark - interface

+ (NSArray *) keyArray
{
	return [self keyArrayForList:gs_fakeListID]; 
}

+ (BOOL) isNewerUpdating
{
	@autoreleasepool 
	{
		return [self isUpdatingWithType:REQUEST_NEWER withListID:gs_fakeListID];
	}
}

+ (NSDate *)lastUpdatedDate
{
	return [self lastUpdatedDateForList:gs_fakeListID];
}

+ (NSDictionary *) getObjectWithStringID:(NSString *)objectID
{
	return [self getObject:objectID inList:gs_fakeListID];
}

#pragma mark - overwrite super class
#pragma mark - overwrite handler

- (void) getMethodHandler:(id)result withListID:(NSString *)listID forward:(BOOL)forward
{
	[super getMethodHandler:result withListID:listID forward:forward];
	
	NSDictionary *messageDict = [(NSDictionary*)result retain];
	
	for (NSDictionary *object in [messageDict objectForKey:@"result"]) 
	{
		[PlaceManager requestObjectWithNumberIDArray:[object valueForKey:@"places"]];
	}
	
	[messageDict release];
}


@end
