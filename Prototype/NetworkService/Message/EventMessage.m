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
	BOOL _updating;
	SEL _handler;
	id _target;
}
@property (retain) NSDictionary *eventDict;
@property (retain) NSArray *eventArray;
@property (retain) NSDate *lastUpdatedDate;
@property (retain) id target;
@property (assign) SEL handler;
@property (assign) BOOL updating;

@end

@implementation EventMessage

@synthesize eventDict = _eventDict;
@synthesize eventArray = _eventArray;
@synthesize lastUpdatedDate = _lastUpdatedDate;
@synthesize updating = _updating;
@synthesize handler = _handler;
@synthesize target = _target;

static EventMessage *gs_shared_instance;

#pragma mark - singleton

- (void) setup
{
	// init data
	@autoreleasepool 
	{
		self.eventDict = [[[NSMutableDictionary alloc] init] autorelease];
		self.updating = NO;
	}
}

- (void) dealloc 
{
	self.eventDict = nil;
	self.eventArray = nil;
	self.lastUpdatedDate = nil;
	self.target = nil;
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
	
	// TODO: remove log
	// LOG(@"Get Message = %@", messageDict);
	
	for (NSDictionary *event in [messageDict objectForKey:@"result"]) 
	{
		[self.eventDict setValue:event forKey:[event objectForKey:@"id"]];
		
		// TODO: remove log
		LOG(@"Get id = %@ Event = %@", [event valueForKey:@"id"], [event valueForKey:@"name"]);
	}
	
	NSArray *unsortedArray = [self.eventDict allValues];
	
	self.eventArray = [unsortedArray sortedArrayUsingFunction:event_sorter context:NULL];
	
	if ((nil != self.target) && (nil != self.handler))
	{
		if ([self.target respondsToSelector:self.handler])
		{
			[self.target performSelector:self.handler];
		}
	}
	
	self.updating = NO;
	
	self.lastUpdatedDate = [NSDate date];
	
	[messageDict release];
}


- (void) requestWithCursor:(int32_t)cursor count:(uint32_t)count forward:(BOOL)forward
{	
	@autoreleasepool 
	{
		NSMutableDictionary *params =  [[[NSMutableDictionary alloc] init] autorelease];
		NSMutableDictionary *request =  [[[NSMutableDictionary alloc] init] autorelease];
		
		[params setValue:[NSNumber numberWithInteger:cursor] forKey:@"cursor"];
		[params setValue:[NSNumber numberWithInteger:count] forKey:@"count"];
		
		[request setValue:@"event.get" forKey:@"method"];
		[request setValue:params forKey:@"params"];
		
		SEND_MSG_AND_BIND_HANDLER(request, self, @selector(messageHandler:));
	}
}

- (void) bindHandler:(SEL)handler withTarget:(id)target
{	
	self.target = target;
	self.handler = handler;
}

- (void) requestNewerWithCount:(uint32_t)count
{
	int32_t newestEventID = -1;
	if (nil != self.eventArray)
	{
		newestEventID = [[[self.eventArray lastObject] valueForKey:@"id"] integerValue];
	}
	
	if (0 < newestEventID)
	{
		[self requestWithCursor:newestEventID count:count forward:false];
	}
	else
	{
		[self requestWithCursor:-1 count:count forward:true];
	}
}

- (void) requestMoreWithCount:(uint32_t)count
{
	int32_t oldestEventID = -1;
	
	if (nil != self.eventArray)
	{
		oldestEventID = [[[self.eventArray lastObject] valueForKey:@"id"] integerValue];
	}
	
	if (0 < oldestEventID)
	{
		[self requestWithCursor:oldestEventID count:count forward:true];
	}
	else
	{
		[self requestWithCursor:-1 count:count forward:true];
	}
}

- (BOOL) requstUpdate
{
	@synchronized (self)
	{
		if (YES == self.updating)
		{
			return NO;
		}
		
		self.updating = YES;
		
		return YES;
	}
}

#pragma mark - interface

+ (void) requestNewerCount:(uint32_t)count withHandler:(SEL)handler andTarget:(id)target
{
	if (NO == [gs_shared_instance requstUpdate])
	{
		return;
	}
	
	// bind target
	[gs_shared_instance bindHandler:handler withTarget:target];
	
	// then send request
	[gs_shared_instance requestNewerWithCount:count];
}

+ (void) requestMoreCount:(uint32_t)count withHandler:(SEL)handler andTarget:(id)target
{
	if (NO == [gs_shared_instance requstUpdate])
	{
		return;
	}
	
	// bind target
	[gs_shared_instance bindHandler:handler withTarget:target];
	
	// then send request
	[gs_shared_instance requestMoreWithCount:count];
}

+ (NSArray*) eventArray
{
	return [gs_shared_instance eventArray]; 
}

+ (BOOL) isUpdating
{
	return gs_shared_instance.updating;
}

+ (NSDate *)lastUpdatedDate
{
	return gs_shared_instance.lastUpdatedDate;
}

@end