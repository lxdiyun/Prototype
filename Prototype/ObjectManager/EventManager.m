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

@interface EventManager ()
{
	NSMutableDictionary *_foodEventIndex;
	NSMutableDictionary *_taskEvents;
}

@property (strong, nonatomic) NSMutableDictionary *foodEventIndex;
@property (strong, nonatomic) NSMutableDictionary *taskEvents;

@end

@implementation EventManager

@synthesize foodEventIndex = _foodEventIndex;
@synthesize taskEvents = _taskEvents;

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
			
			if (nil == self.foodEventIndex)
			{
				self.foodEventIndex = [[[NSMutableDictionary alloc] init] autorelease];
			}
			
			if (nil == self.taskEvents)
			{
				self.taskEvents = [[[NSMutableDictionary alloc] init] autorelease];
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
	self.foodEventIndex = nil;
	
	[super dealloc];
}


#pragma mark - send request message

+ (void) requestNewestCount:(uint32_t)count withHandler:(SEL)handler andTarget:(id)target
{
	return [self requestNewestWithListID:gs_fakeListID 
				   andCount:count 
				withHandler:handler 
				   andTarget:target];
}

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

+ (NSInteger) keyCount
{
	NSArray *eventKeys = [self keyArrayForList:gs_fakeListID];
	NSArray *taskEventKeys = [[[self getInstnace] taskEvents] allKeys];
	
	return eventKeys.count + taskEventKeys.count;
}

+ (NSArray *) keyArray
{
	NSArray *eventKeys = [self keyArrayForList:gs_fakeListID];
	NSArray *taskEventKeys = [[[self getInstnace] taskEvents] allKeys];
	// task event must be show in front of normal event
	NSMutableArray *allKeys = [NSMutableArray arrayWithArray:taskEventKeys];
	
	[allKeys addObjectsFromArray:eventKeys];

	return allKeys; 
}

+ (BOOL) isNewestUpdating
{
	@autoreleasepool 
	{
		return [self isUpdatingWithType:REQUEST_NEWEST withListID:gs_fakeListID];
	}
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
	if ([objectID hasPrefix:EVENT_TASK_ID_PREFIX]) 
	{
		return [[[self getInstnace] taskEvents] valueForKey:objectID];
	}

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
			NSNumber *foodID = [object valueForKey:@"id"];
			NSNumber *eventID = [result valueForKey:@"id"];
			
			[FoodManager setObject:object withNumberID:foodID];
			[self.foodEventIndex setValue:eventID forKey:[foodID stringValue]];
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

#pragma mark - delete events

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

+ (void) removeEventByFood:(NSNumber *)foodID
{
	NSNumber *eventID = [[[self getInstnace] foodEventIndex] valueForKey:[foodID stringValue]];

	if (nil != eventID)
	{
		[self setObject:nil withStringID:[eventID stringValue] inList:gs_fakeListID];
	}
}

#pragma mark - task event

+ (void) addTaskEvent:(NSMutableDictionary *)event with:(Task *)task
{
	NSString *taskEventID = [[NSString alloc] initWithFormat:@"%@%@", EVENT_TASK_ID_PREFIX, task.taskID];
	
	[event setValue:taskEventID forKey:@"id"];
	
	[[[self getInstnace] taskEvents] setValue:event forKey:taskEventID];
	
	[taskEventID release];
}

+ (void) removeTaskEvent:(Task *)task
{
	NSString *taskEventID = [[NSString alloc] initWithFormat:@"%@%@", EVENT_TASK_ID_PREFIX, task.taskID];
	
	[[[self getInstnace] taskEvents] setValue:nil forKey:taskEventID];
	
	[taskEventID release];
}

@end
