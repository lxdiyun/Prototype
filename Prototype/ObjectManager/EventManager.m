//
//  Created by Adrian Lee on 12/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "EventManager.h"

#import "Util.h"
#import "Message.h"
#import "ImageManager.h"
#import "ProfileMananger.h"
#import "FoodManager.h"

static NSString *gs_fakeListID = nil;

@implementation EventManager

#pragma mark - singleton

DEFINE_SINGLETON(EventManager);

#pragma mark - life circle

- (id) init 
{
	self = [super init];
	
	if (nil != self) 
	{
		@autoreleasepool 
		{
			if (nil == gs_fakeListID)
			{
				gs_fakeListID = [[NSString alloc] initWithFormat:@"%d", 0x1];
			}
			
			self.getMethodString = @"event.get";
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

+ (NSDate *) lastUpdatedDate
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
	NSMutableSet *newPicSet = [[NSMutableSet alloc] init];
	NSMutableSet *newUserSet = [[NSMutableSet alloc] init];
	
	for (NSDictionary *result in [messageDict objectForKey:@"result"]) 
	{
		NSDictionary *object = [result valueForKey:@"obj"];

		NSNumber *picID = [object valueForKey:@"pic"];
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
		
		NSNumber *userID = [object valueForKey:@"user"];
		
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
		
		NSString *objecType = [result valueForKey:@"obj_type"];
		
		// save food object
		if ([objecType isEqualToString:@"food"])
		{
			[FoodManager setObject:object
				  withNumberID:[object valueForKey:@"id"]];
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

#pragma mark - class method

+ (void) removeEventsForUser:(NSNumber *)userID
{
	NSDictionary *allEvents = [[[self getInstnace] objectDict] valueForKey:gs_fakeListID];
	
	for (NSString *eventKey in [allEvents allKeys]) 
	{
		NSDictionary *object = [[allEvents valueForKey:eventKey] valueForKey:@"obj"] ;
		
		if (CHECK_EQUAL(userID, [object valueForKey:@"user"]))
		{
			[allEvents setValue:nil forKey:eventKey];
		}
	}
	
	[[self getInstnace] updateKeyArrayForList:gs_fakeListID withResult:nil forward:NO];
}

@end
