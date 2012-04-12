//
//  EventMessage.m
//  Prototype
//
//  Created by Adrian Lee on 12/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "EventMessage.h"

#import "Util.h"
#import "Message.h"
#import "ImageManager.h"

typedef enum EVENT_MESSAGE_TYPE_ENUM
{
	REQUEST_NEWER = 0x0,
	REQUEST_OLDER = 0x1,
	MAX_EVENT_MESSAGE = 0x2
} EVENT_MESSAGE_TYPE;

@interface EventMessage () 
{
	NSArray *_eventArray;
	NSDate *_lastUpdatedDate;
	BOOL _updating[MAX_EVENT_MESSAGE];
	id _target[MAX_EVENT_MESSAGE];
	SEL _handler[MAX_EVENT_MESSAGE];
}
@property (retain) NSArray *eventArray;
@property (retain) NSDate *lastUpdatedDate;

@end

@implementation EventMessage

@synthesize eventArray = _eventArray;
@synthesize lastUpdatedDate = _lastUpdatedDate;

#pragma mark - life circle

- (id) init
{
	self = [super init];
	
	if (nil != self)
	{
		// init data
		@autoreleasepool 
		{
			for (int i = 0; i < MAX_EVENT_MESSAGE; ++i)
			{
				_updating[i] = NO; 
			}
		}
	}
	
	return self;
}

- (void) dealloc 
{
	self.eventArray = nil;
	self.lastUpdatedDate = nil;
	
	for (int i = 0; i < MAX_EVENT_MESSAGE; ++i)
	{
		[_target[i] release];
		_target[i] = nil; 
	}
	
	[super dealloc];
}

#pragma mark - singleton

DEFINE_SINGLETON(EventMessage);

#pragma mark - message

- (void)messageHandler:(id)dict
{
	if (![dict isKindOfClass: [NSDictionary class]])
	{
		return;
	}

	NSDictionary *messageDict = [(NSDictionary*)dict retain];

	NSMutableArray *newPicArray = [[NSMutableArray alloc] init];
	
	for (NSDictionary *event in [messageDict objectForKey:@"result"]) 
	{
		[self.objectDict setValue:event forKey:[[event valueForKey:@"id"] stringValue]];

		NSNumber *picID = [[event valueForKey:@"obj"] valueForKey:@"pic"];
		if (nil == [ImageManager getObjectWithNumberID:picID])
		{
			[newPicArray addObject:picID];
		}
	}

	// buffer the new image info
	[ImageManager requestImageWithNumberIDArray:newPicArray];

	[newPicArray release];

	// update event ID array
	self.eventArray = [[self.objectDict allKeys] sortedArrayUsingFunction:ID_SORTER context:nil];

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
	
	[params setValue:[NSNumber numberWithBool:forward] forKey:@"forwarding"];
	
	[request setValue:@"event.get" forKey:@"method"];
	[request setValue:params forKey:@"params"];
	
	return request;
}

- (void) bindMessageType:(EVENT_MESSAGE_TYPE)type withHandler:(SEL)handler andTarget:(id)target
{
	@autoreleasepool 
	{
		[_target[type] autorelease];
		_target[type] = [target retain];
		_handler[type] = handler; 
	}
}

- (void) requestNewerWithCount:(uint32_t)count
{
	@autoreleasepool 
	{
		int32_t newestEventID = -1;
		NSDictionary *request;
		
		if (nil != self.eventArray)
		{
			newestEventID = [[self.eventArray lastObject] integerValue];
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
			oldestEventID = [[self.eventArray lastObject]  integerValue];
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
		
		SEND_MSG_AND_BIND_HANDLER_WITH_PRIOIRY(request, 
						       self, 
						       @selector(requestOlderHandler:), 
						       NORMAL_PRIORITY);
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
	if (NO == [[self getInstnace] requestUpdateWith:REQUEST_NEWER])
	{
		return;
	}

	// bind target
	[[self getInstnace] bindMessageType:REQUEST_NEWER withHandler:handler andTarget:target];

	// then send request
	[[self getInstnace] requestNewerWithCount:count];
}

+ (void) requestOlderCount:(uint32_t)count withHandler:(SEL)handler andTarget:(id)target
{
	if (NO == [[self getInstnace] requestUpdateWith:REQUEST_OLDER])
	{
		return;
	}

	// bind target
	[[self getInstnace] bindMessageType:REQUEST_OLDER withHandler:handler andTarget:target];

	// then send request
	[[self getInstnace] requestOlderWithCount:count];
}

+ (NSArray *) eventKeyArray
{
	return [self getInstnace].eventArray; 
}

+ (BOOL) isNewerUpdating
{
	return [[self getInstnace] isUpdatingMessage:REQUEST_NEWER];
}

+ (BOOL) isOlderUpdating
{
	return [[self getInstnace] isUpdatingMessage:REQUEST_OLDER];
}

+ (NSDate *)lastUpdatedDate
{
	return [self getInstnace].lastUpdatedDate;
}

@end
