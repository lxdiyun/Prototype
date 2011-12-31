//
//  EventMessage.m
//  Prototype
//
//  Created by Adrian Lee on 12/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "EventMessage.h"

#import "Util.h"

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
	BOOL _newerUpdating;
	SEL _requestNewerHandler;
	id _requestNewerTarget;
	BOOL _olderUpdating;
	SEL _requestOlderHandler;
	id _requestOlderTarget;
}
@property (retain) NSDictionary *eventDict;
@property (retain) NSArray *eventArray;
@property (retain) NSDate *lastUpdatedDate;
@property (assign) BOOL newerUpdating;
@property (retain) id requestNewerTarget;
@property (assign) SEL requestNewerHandler;
@property (assign) BOOL olderUpdating;
@property (retain) id requestOlderTarget;
@property (assign) SEL requestOlderHandler;

@end

@implementation EventMessage

@synthesize eventDict = _eventDict;
@synthesize eventArray = _eventArray;
@synthesize lastUpdatedDate = _lastUpdatedDate;
@synthesize newerUpdating = _newerUpdating;
@synthesize requestNewerHandler = _requestNewerHandler;
@synthesize requestNewerTarget = _requestNewerTarget;
@synthesize olderUpdating = _olderUpdating;
@synthesize requestOlderHandler = _requestOlderHandler;
@synthesize requestOlderTarget = _requestOlderTarget;

static EventMessage *gs_shared_instance;

#pragma mark - singleton

- (void) setup
{
	// init data
	@autoreleasepool 
	{
		self.eventDict = [[[NSMutableDictionary alloc] init] autorelease];
		self.newerUpdating = NO;
		self.olderUpdating = NO;
	}
}

- (void) dealloc 
{
	self.eventDict = nil;
	self.eventArray = nil;
	self.lastUpdatedDate = nil;
	self.requestNewerTarget = nil;
	self.requestOlderTarget = nil;
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

- (void)requestNewerHandler:(id)dict
{
	[self messageHandler:dict];

	if ((nil != self.requestNewerTarget) && (nil != self.requestNewerHandler))
	{
		if ([self.requestNewerTarget respondsToSelector:self.requestNewerHandler])
		{
			[self.requestNewerTarget performSelector:self.requestNewerHandler];
		}
	}

	self.newerUpdating = NO;
}

- (void)requestOlderHandler:(id)dict
{
	[self messageHandler:dict];

	if ((nil != self.requestOlderTarget) && (nil != self.requestOlderHandler))
	{
		if ([self.requestOlderTarget respondsToSelector:self.requestOlderHandler])
		{
			[self.requestOlderTarget performSelector:self.requestOlderHandler];
		}
	}

	self.olderUpdating = NO;
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

- (void) bindNewerHandler:(SEL)handler withTarget:(id)target
{	
	self.requestNewerTarget = target;
	self.requestNewerHandler = handler;
}

- (void) bindOlderHandler:(SEL)handler withTarget:(id)target
{	
	self.requestOlderTarget = target;
	self.requestOlderHandler = handler;
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

- (BOOL) requstNewerUpdate
{
	@synchronized (self)
	{
		if (YES == self.newerUpdating)
		{
			return NO;
		}

		self.newerUpdating = YES;

		return YES;
	}
}

- (BOOL) requstOlderUpdate
{
	@synchronized (self)
	{
		if (YES == self.olderUpdating)
		{
			return NO;
		}

		self.olderUpdating = YES;

		return YES;
	}
}

#pragma mark - interface

+ (void) requestNewerCount:(uint32_t)count withHandler:(SEL)handler andTarget:(id)target
{
	if (NO == [gs_shared_instance requstNewerUpdate])
	{
		return;
	}

	// bind target
	[gs_shared_instance bindNewerHandler:handler withTarget:target];

	// then send request
	[gs_shared_instance requestNewerWithCount:count];
}

+ (void) requestOlderCount:(uint32_t)count withHandler:(SEL)handler andTarget:(id)target
{
	if (NO == [gs_shared_instance requstOlderUpdate])
	{
		return;
	}

	// bind target
	[gs_shared_instance bindOlderHandler:handler withTarget:target];

	// then send request
	[gs_shared_instance requestOlderWithCount:count];
}

+ (NSArray *) eventArray
{
	return [gs_shared_instance eventArray]; 
}

+ (BOOL) isNewerUpdating
{
	return gs_shared_instance.newerUpdating;
}

+ (BOOL) isOlderUpdating
{
	return gs_shared_instance.olderUpdating;
}

+ (NSDate *)lastUpdatedDate
{
	return gs_shared_instance.lastUpdatedDate;
}

@end
