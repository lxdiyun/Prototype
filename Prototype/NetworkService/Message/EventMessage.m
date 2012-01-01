//
//  EventMessage.m
//  Prototype
//
//  Created by Adrian Lee on 12/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "EventMessage.h"

#import "Util.h"

typedef enum EVENT_MESSAGE_TYPE_ENUM
{
	REQUEST_NEWER = 0x0,
	REQUEST_OLDER = 0x1,
	MAX_EVENT_MESSAGE = 0x2
} EVENT_MESSAGE_TYPE;

#pragma mark - Auxiliary C function
static NSInteger event_sorter(id event1, id event2, void *context)
{
	uint32_t v1 = [[event1 valueForKey:@"id"] integerValue];
	uint32_t v2 = [[event2 valueForKey:@"id"] integerValue];
	if (v1 > v2)
		return NSOrderedAscending;
	else if (v1 < v2)
		return NSOrderedDescending;
	else
		return NSOrderedSame;
}

@interface EventMessage () 
{
	NSMutableDictionary *_eventDict;
	NSArray *_eventArray;
	NSDate *_lastUpdatedDate;
	BOOL _updating[MAX_EVENT_MESSAGE];
	id _target[MAX_EVENT_MESSAGE];
	SEL _handler[MAX_EVENT_MESSAGE];
}
@property (retain) NSDictionary *eventDict;
@property (retain) NSArray *eventArray;
@property (retain) NSDate *lastUpdatedDate;

@end

@implementation EventMessage

@synthesize eventDict = _eventDict;
@synthesize eventArray = _eventArray;
@synthesize lastUpdatedDate = _lastUpdatedDate;

static EventMessage *gs_shared_instance;

#pragma mark - singleton

- (void) setup
{
	// init data
	@autoreleasepool 
	{
		self.eventDict = [[[NSMutableDictionary alloc] init] autorelease];
		for (int i = 0; i < MAX_EVENT_MESSAGE; ++i)
		{
			_updating[i] = NO; 
		}
	}
}

- (void) dealloc 
{
	self.eventDict = nil;
	self.eventArray = nil;
	self.lastUpdatedDate = nil;
}

+ (id) allocWithZone:(NSZone *)zone 
{
	return [gs_shared_instance retain];
}

- (id) copyWithZone:(NSZone *)zone 
{
	return self;
}

#if (!__has_feature(objc_arc))
- (id) retain 
{
	return self;
}

- (unsigned) retainCount
{
	return UINT_MAX;  //denotes an object that cannot be released
}

- (oneway void) release 
{
	//do nothing
}

- (id) autorelease 
{
	return self;
}
#endif

+ (void) initialize 
{
	if (self == [EventMessage class]) 
	{
		gs_shared_instance = [[super allocWithZone:nil] init];
		[gs_shared_instance setup];
	}
}

+ (EventMessage*) getInstnace
{
	return gs_shared_instance;
}


#pragma mark - message

- (void)messageHandler:(id)dict
{
	if (![dict isKindOfClass: [NSDictionary class]])
	{
		LOG(@"Error handle non dict object");
		return;
	}

	NSDictionary *messageDict = [(NSDictionary*)dict retain];

	for (NSDictionary *event in [messageDict objectForKey:@"result"]) 
	{
		[self.eventDict setValue:event forKey:[event objectForKey:@"id"]];

		// TODO: remove log
		LOG(@"Get id = %@ Event = %@", [event valueForKey:@"id"], [event valueForKey:@"name"]);
	}

	NSArray *unsortedArray = [self.eventDict allValues];

	self.eventArray = [unsortedArray sortedArrayUsingFunction:event_sorter context:NULL];

	[messageDict release];
}

- (void) requestHandlerWithType:(EVENT_MESSAGE_TYPE)type withDict:(id)dict
{
	[self messageHandler:dict];
	
	if ((nil != _target[type]) && (nil != _handler[type]))
	{
		if ([_target[type] respondsToSelector:_handler[type]])
		{
			[_target[type] performSelector:_handler[type]];
		}
	}
	
	_updating[type] = NO;
}

- (void) requestNewerHandler:(id)dict
{
	[self requestHandlerWithType:REQUEST_NEWER withDict:dict];
}

- (void) requestOlderHandler:(id)dict
{
	[self requestHandlerWithType:REQUEST_OLDER withDict:dict];
}

- (NSDictionary *) requestWithCursor:(int32_t)cursor count:(uint32_t)count forward:(BOOL)forward
{	
	NSMutableDictionary *params =  [[[NSMutableDictionary alloc] init] autorelease];
	NSMutableDictionary *request =  [[[NSMutableDictionary alloc] init] autorelease];
	
	[params setValue:[NSNumber numberWithInteger:cursor] forKey:@"cursor"];
	[params setValue:[NSNumber numberWithInteger:count] forKey:@"count"];
	
	[request setValue:@"event.get" forKey:@"method"];
	[request setValue:params forKey:@"params"];
	
	return request;
}

- (void) bindMessageType:(EVENT_MESSAGE_TYPE)type withHandler:(SEL)handler andTarget:(id)target
{
	_target[type] = target;
	_handler[type] = handler; 
}

- (void) requestNewerWithCount:(uint32_t)count
{
	@autoreleasepool 
	{
		int32_t newestEventID = -1;
		NSDictionary *request;
		
		if (nil != self.eventArray)
		{
			newestEventID = [[[self.eventArray lastObject] valueForKey:@"id"] integerValue];
		}
		
		self.lastUpdatedDate = [NSDate date];
		
		if (0 < newestEventID)
		{
			request = [self requestWithCursor:newestEventID count:count forward:false];
		}
		else
		{
			request = [self requestWithCursor:-1 count:count forward:true];
		}
		
		SEND_MSG_AND_BIND_HANDLER(request, self, @selector(requestNewerHandler:));
	}
}

- (void) requestOlderWithCount:(uint32_t)count
{
	@autoreleasepool 
	{
		int32_t oldestEventID = -1;
		NSDictionary *request;
		
		if (nil != self.eventArray)
		{
			oldestEventID = [[[self.eventArray lastObject] valueForKey:@"id"] integerValue];
		}
		
		if (0 < oldestEventID)
		{
			request = [self requestWithCursor:oldestEventID count:count forward:true];
		}
		else
		{
			// empty event list, also need to updae the last updated date 
			self.lastUpdatedDate = [NSDate date];
			request = [self requestWithCursor:-1 count:count forward:true];
		}
		
		SEND_MSG_AND_BIND_HANDLER(request, self, @selector(requestOlderHandler:));
	}
}

- (BOOL) requestUpdateWith:(EVENT_MESSAGE_TYPE)type
{
	@synchronized (self)
	{
		if (YES == _updating[type])
		{
			return NO;
		}
		
		_updating[type] = YES;
		
		return YES;
	}
}

- (BOOL) isUpdatingMessage:(EVENT_MESSAGE_TYPE)type
{
	return _updating[type];
}

#pragma mark - interface

+ (void) requestNewerCount:(uint32_t)count withHandler:(SEL)handler andTarget:(id)target
{
	if (NO == [gs_shared_instance requestUpdateWith:REQUEST_NEWER])
	{
		return;
	}

	// bind target
	[gs_shared_instance bindMessageType:REQUEST_NEWER withHandler:handler andTarget:target];

	// then send request
	[gs_shared_instance requestNewerWithCount:count];
}

+ (void) requestOlderCount:(uint32_t)count withHandler:(SEL)handler andTarget:(id)target
{
	if (NO == [gs_shared_instance requestUpdateWith:REQUEST_OLDER])
	{
		return;
	}

	// bind target
	[gs_shared_instance bindMessageType:REQUEST_OLDER withHandler:handler andTarget:target];

	// then send request
	[gs_shared_instance requestOlderWithCount:count];
}

+ (NSArray *) eventArray
{
	return [gs_shared_instance eventArray]; 
}

+ (BOOL) isNewerUpdating
{
	return [gs_shared_instance isUpdatingMessage:REQUEST_NEWER];
}

+ (BOOL) isOlderUpdating
{
	return [gs_shared_instance isUpdatingMessage:REQUEST_OLDER];
}

+ (NSDate *)lastUpdatedDate
{
	return gs_shared_instance.lastUpdatedDate;
}

@end
