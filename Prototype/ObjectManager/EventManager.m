//
//  Created by Adrian Lee on 12/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "EventManager.h"

#import "Util.h"
#import "Message.h"
#import "ImageManager.h"
#import "ProfileMananger.h"

static NSString *gs_fakeEventID = nil;

@implementation EventManager

#pragma mark - singleton

DEFINE_SINGLETON(EventManager);

#pragma mark - life circle

- (id) init 
{
	self = [super init];
	
	if (nil != self) 
	{
		if (nil == gs_fakeEventID)
		{
			gs_fakeEventID = [[NSString alloc] initWithFormat:@"%d", 0x1];
		}
	}
	
	return self;
}

- (void) dealloc
{
	gs_fakeEventID = nil;
	[super dealloc];
}


#pragma mark - send request message

+ (void) requestNewerCount:(uint32_t)count withHandler:(SEL)handler andTarget:(id)target
{
	return [self requestNewerWithListID:gs_fakeEventID 
				   andCount:count 
				withHandler:handler 
				  andTarget:target];
}
+ (void) requestOlderCount:(uint32_t)count withHandler:(SEL)handler andTarget:(id)target
{
	return [self requestOlderWithListID:gs_fakeEventID 
				   andCount:count 
				withHandler:handler 
				  andTarget:target];
}

#pragma mark - interface

+ (NSArray *) eventKeyArray
{
	return [self keyArrayForList:gs_fakeEventID]; 
}

+ (BOOL) isNewerUpdating
{
	@autoreleasepool 
	{
		return [self isUpdatingWithType:REQUEST_NEWER withListID:gs_fakeEventID];
	}
}

+ (NSDate *)lastUpdatedDate
{
	return [self lastUpdatedDateForList:gs_fakeEventID];
}

+ (NSDictionary *) getObjectWithStringID:(NSString *)objectID
{
	return [self getObject:objectID inList:gs_fakeEventID];
}

#pragma mark - overwrite super class
#pragma mark - overwrite handler

- (void) messageHandler:(id)dict withListID:(NSString *)ID
{
	[super messageHandler:dict withListID:ID];
	
	NSDictionary *messageDict = [(NSDictionary*)dict retain];
	NSMutableSet *newPicSet = [[NSMutableSet alloc] init];
	NSMutableSet *newUserSet = [[NSMutableSet alloc] init];
	
	for (NSDictionary *object in [messageDict objectForKey:@"result"]) 
	{
		NSNumber *picID = [[object valueForKey:@"obj"] valueForKey:@"pic"];
		if (CHECK_NUMBER(picID))
		{
			if (nil == [ImageManager getObjectWithNumberID:picID])
			{
				[newPicSet addObject:picID];
			}
		}
		else
		{
			LOG(@"Error failed to get picID from \n:%@", object);
		}
		
		NSNumber *userID = [[object valueForKey:@"obj"] objectForKey:@"user"];
		
		if (CHECK_NUMBER(userID))
		{
			if (nil == [ProfileMananger getObjectWithNumberID:userID])
			{
				[newUserSet addObject:userID];
			}
		}
		else
		{
			LOG(@"Error failed to get userID from \n:%@", object);
		}
		
	}
	
	// cache the new image info
	[ImageManager requestObjectWithNumberIDArray:[newPicSet allObjects]];
	
	// cacahe the new user info
	[ProfileMananger requestObjectWithNumberIDArray:[newUserSet allObjects]];
	
	[newUserSet release];
	[newPicSet release];
	[messageDict release];
}

#pragma mark - overwrite requsest get method

- (NSString *) getMethod
{
	return @"event.get";
}

- (void) setGetMethodParams:(NSMutableDictionary *)params forList:(NSString *)listID
{
	// do nothing
}


@end
