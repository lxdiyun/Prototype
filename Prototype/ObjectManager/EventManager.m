//
//  EventMessage.m
//  Prototype
//
//  Created by Adrian Lee on 12/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "EventManager.h"

#import "Util.h"
#import "Message.h"
#import "ImageManager.h"

typedef enum EVENT_MESSAGE_TYPE_ENUM
{
	REQUEST_NEWER = 0x0,
	REQUEST_OLDER = 0x1,
	MAX_EVENT_MESSAGE = 0x2
} EVENT_MESSAGE_TYPE;

@interface EventManager () 
{
	NSArray *_eventKeyArray;
	NSDate *_lastUpdatedDate;
}
@property (retain) NSArray *eventKeyArray;
@property (retain) NSDate *lastUpdatedDate;

@end

@implementation EventManager

@synthesize eventKeyArray = _eventKeyArray;
@synthesize lastUpdatedDate = _lastUpdatedDate;

#pragma mark - life circle

- (void) dealloc 
{
	self.eventKeyArray = nil;
	self.lastUpdatedDate = nil;
	
	[super dealloc];
}

#pragma mark - singleton

DEFINE_SINGLETON(EventManager);

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
	self.eventKeyArray = [[self.objectDict allKeys] sortedArrayUsingFunction:ID_SORTER context:nil];

	[messageDict release];
}

- (void) requestHandlerWithType:(EVENT_MESSAGE_TYPE)type withDict:(id)dict
{	
	[self messageHandler:dict];
	
	NSString *typeID = [[NSString alloc] initWithFormat:@"%d", type];
	MessageResponder *responder = [self.responderArrayDict valueForKey:typeID];
	
	[self.updatingDict setValue:[NSNumber numberWithBool:NO] forKey:typeID];
	
	if (nil != responder)
	{
		[responder perform];
	}
	
	[typeID release];
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
		if ((nil != handler) && (nil != target))
		{
			NSString *typeID = [[NSString alloc] initWithFormat:@"%d", type];
			MessageResponder *responder = [[MessageResponder alloc] init];
			
			responder.target = target;
			responder.handler = handler;
			[self.responderArrayDict setValue:responder forKey:typeID];
			
			[responder release];
			[typeID release];
		}
	}
}

- (void) requestNewerWithCount:(uint32_t)count
{
	@autoreleasepool 
	{
		int32_t newestEventID = -1;
		NSDictionary *request;
		
		if (nil != self.eventKeyArray)
		{
			newestEventID = [[self.eventKeyArray lastObject] integerValue];
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
		
		if (nil != self.eventKeyArray)
		{
			oldestEventID = [[self.eventKeyArray lastObject]  integerValue];
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
	@autoreleasepool 
	{
		@synchronized (self)
		{
			NSNumber *typeID = [[[NSNumber alloc] initWithInt:type] autorelease];
			if (YES == [[self class] isUpdatingObjectNumberID:typeID])
			{
				return NO;
			}
			
			[[self class] markUpdatingNumberID:typeID];
			
			return YES;
		}
	}	
}

- (BOOL) isUpdatingMessage:(EVENT_MESSAGE_TYPE)type
{
	@autoreleasepool 
	{
		return [[self class] isUpdatingObjectNumberID:[NSNumber numberWithInt:type]];
	}

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
	return [self getInstnace].eventKeyArray; 
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
