//
//  ObjectManager.m
//  Prototype
//
//  Created by Adrian Lee on 1/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ObjectManager.h"

#import "Util.h"
#import "Message.h"

@interface ObjectManager ()
{
	NSMutableDictionary *_objectDict;
	NSMutableDictionary *_responderArrayDict;
	NSMutableDictionary *_updatingDict;
	NSArray *_IDArray;
}
@end

@implementation ObjectManager

@synthesize objectDict = _objectDict;
@synthesize responderArrayDict = _responderArrayDict;
@synthesize updatingDict = _updatingDict;

#pragma mark - life circle

- (id) init
{
	self = [super init];

	if (nil != self)
	{
		// init data
		@autoreleasepool 
		{
			self.objectDict = [[[NSMutableDictionary alloc] init] autorelease];
			self.responderArrayDict = [[[NSMutableDictionary alloc] init] autorelease];
			self.updatingDict = [[[NSMutableDictionary alloc] init] autorelease];
		}
	}

	return self;
}

- (void) dealloc 
{
	self.objectDict = nil;
	self.responderArrayDict = nil;
	self.updatingDict = nil;

	[super dealloc];
}

+ (id) getInstnace
{
	LOG(@"Error should not get here");
	return nil;
}

#pragma mark - updating flag

- (void) markUpdatingStringID:(NSString *)ID
{
	[self.updatingDict setValue:[NSNumber numberWithBool:YES] forKey:ID];
}

- (void) clearnUpdatingStringID:(NSString *)ID
{
	[self.updatingDict setValue:[NSNumber numberWithBool:NO] forKey:ID];
}

#pragma mark - resoponder

- (void) checkAndPerformResponderWithID:(NSString *)ID
{
	@autoreleasepool 
	{
		NSArray *responderArray;

		@synchronized (_responderArrayDict)
		{
			responderArray = [[self.responderArrayDict valueForKey:ID] retain];
			[self.responderArrayDict setValue:nil forKey:ID];
			[responderArray autorelease];
		}

		if (nil != responderArray)
		{
			for (MessageResponder *responder in responderArray)
			{
				[responder perform];
			}
		}
	}
}

- (void) checkAndPerformResponderWithStringIDArray:(NSArray *)IDArray
{
	@synchronized (_responderArrayDict)
	{
		NSArray *responderArray;

		for (NSString *ID in IDArray)
		{
			responderArray = [[self.responderArrayDict valueForKey:ID] retain];
			[self.responderArrayDict setValue:nil forKey:ID];

			if (nil != responderArray)
			{
				for (MessageResponder *responder in responderArray)
				{
					[responder perform];
				}
			}

			[responderArray release];
		}
	}
}

- (void) bindID:(NSString *)ID withResponder:(MessageResponder*)responder
{
	@synchronized (_responderArrayDict)
	{
		NSMutableArray *responderArray =  [self.responderArrayDict valueForKey:ID];

		if (nil == responderArray)
		{
			responderArray = [[NSMutableArray alloc] initWithObjects:responder, nil];
			[self.responderArrayDict setValue:responderArray forKey:ID];
			[responderArray release];
		}
		else
		{
			[responderArray addObject:responder];
		}
	}
}

#pragma mark - message handler

- (void) handlerForSingleResult:(id)result
{
	if (![result isKindOfClass: [NSDictionary class]])
	{
		LOG(@"Error handle non dict object");
		return;
	}

	NSDictionary *objectDict = [result valueForKey:@"result"];
	NSString *objectID = [[objectDict valueForKey:@"id"] stringValue];

	[self.objectDict setValue:objectDict forKey:objectID];
	[self clearnUpdatingStringID:objectID];
	[self checkAndPerformResponderWithID:objectID];
}

- (void) handlerForArrayResult:(id)result
{
	if (![result isKindOfClass: [NSDictionary class]])
	{
		LOG(@"Error handle non dict object");
		return;
	}

	NSMutableArray *newObjectArray = [[NSMutableArray alloc] init];


	for (NSDictionary *object in [result objectForKey:@"result"]) 
	{
		NSString *objectID = [[object valueForKey:@"id"] stringValue];

		[self.objectDict setValue:object forKey:objectID];
		[self clearnUpdatingStringID:objectID];
		[newObjectArray addObject:objectID];
	}

	[self checkAndPerformResponderWithStringIDArray:newObjectArray];
	[newObjectArray release];

}

#pragma mark - message request

- (void) requestObjectWithRequest:(NSDictionary *)request
{
	SEND_MSG_AND_BIND_HANDLER_WITH_PRIOIRY(request, self, @selector(handlerForSingleResult:), NORMAL_PRIORITY);
}

- (void) requestObjectArrayWithRequest:(NSDictionary *)request
{
	SEND_MSG_AND_BIND_HANDLER_WITH_PRIOIRY(request, self, @selector(handlerForArrayResult:), NORMAL_PRIORITY);
}

# pragma mark - message request get

+ (NSString *) getMethod
{
	LOG(@"Error should use the subclass method");
	return nil;
}

+ (void) requestObjectWithNumberID:(NSNumber *)ID andHandler:(SEL)handler andTarget:(id)target
{
	if (CHECK_NUMBER(ID))
	{
		// bind handler
		[self bindNumberID:ID withHandler:handler andTarget:target];	

		// then send message
		NSMutableDictionary *request = [[NSMutableDictionary alloc] init];

		[request setValue:[self getMethod] forKey:@"method"];

		[self sendObjectRequest:request withNumberID:ID];

		[request release];
	}
}

+ (void) requestObjectWithNumberIDArray:(NSArray *)numberIDArray
{	
	// no handler just send the message
	NSMutableDictionary *request = [[NSMutableDictionary alloc] init];

	[request setValue:[self getMethod] forKey:@"method"];

	[self sendObjectArrayRequest:request withNumberIDArray:numberIDArray];

	[request release];
}

#pragma mark - interface

+ (NSDictionary *) getObjectWithStringID:(NSString *)ID
{
	if (CHECK_STRING(ID))
	{
		return [[[self getInstnace] objectDict] valueForKey:ID];
	}
	else
	{
		return nil;
	}
}

+ (NSDictionary *) getObjectWithNumberID:(NSNumber *)ID
{
	if (CHECK_NUMBER(ID))
	{
		return [self getObjectWithStringID:[ID stringValue]];
	}
	else
	{
		return nil;
	}
}

+ (void) bindStringID:(NSString *)ID withHandler:(SEL)handler andTarget:(id)target
{
	if (!CHECK_STRING(ID))
	{
		return;
	}
	
	if ((target != nil) && (handler != nil))
	{
		MessageResponder *responder = [[MessageResponder alloc] init];
		responder.target = target;
		responder.handler = handler;
		[[self getInstnace] bindID:ID withResponder:responder];

		[responder release];
	}
}

+ (void) bindNumberID:(NSNumber *)ID withHandler:(SEL)handler andTarget:(id)target
{
	[self bindStringID:[ID stringValue] withHandler:handler andTarget:target];
}

+ (void) sendObjectRequest:(NSDictionary *)request withNumberID:(NSNumber *)ID
{
	if (!CHECK_NUMBER(ID))
	{
		return;
	}
	
	if (NO == [self isUpdatingObjectNumberID:ID])
	{
		[self markUpdatingNumberID:ID];
		[request setValue:ID  forKey:@"params"];
		[[self getInstnace] requestObjectWithRequest:request];
	}
}

+ (void) sendObjectArrayRequest:(NSDictionary *)request withNumberIDArray:(NSArray *)IDArray;
{
	if (nil != IDArray)
	{
		NSMutableSet *checkedSet = [[NSMutableSet alloc] init];

		for (NSNumber *ID in IDArray) 
		{
			if (!CHECK_NUMBER(ID))
			{
				continue;
			}
			
			if (NO == [self isUpdatingObjectNumberID:ID])
			{
				[checkedSet addObject:ID];
				[self markUpdatingNumberID:ID];
			}
		}

		if (0 < checkedSet.count)
		{
			[request setValue:[checkedSet allObjects] forKey:@"params"];
			[[self getInstnace] requestObjectArrayWithRequest:request];
		}

		[checkedSet release];
	}
}

+ (void) markUpdatingStringID:(NSString *)ID
{
	if (!CHECK_STRING(ID))
	{
		return;
	}
	
	[[self getInstnace] markUpdatingStringID:ID];
}

+ (void) markUpdatingNumberID:(NSNumber *)ID
{
	if (!CHECK_NUMBER(ID))
	{
		return;
	}
	
	[self markUpdatingStringID:[ID stringValue]];
}

+ (void) markUpdatingNumberIDArray:(NSArray *)IDArray
{
	for (NSNumber *ID in IDArray)
	{
		if (!CHECK_NUMBER(ID))
		{
			continue;
		}

		[self markUpdatingNumberID:ID];
	}
}

+ (void) cleanUpdatingStringID:(NSString *)ID
{
	if (!CHECK_STRING(ID))
	{
		return;
	}
	
	[[self getInstnace] clearnUpdatingStringID:ID];
}

+ (void) cleanUpdatingNumberID:(NSNumber *)ID
{
	if (!CHECK_NUMBER(ID))
	{
		return;
	}
	
	[self cleanUpdatingStringID:[ID stringValue]];
}

+ (BOOL) isUpdatingObjectStringID:(NSString *)ID
{
	if (!CHECK_STRING(ID))
	{
		return NO;
	}
	
	NSNumber *updating = [[[self getInstnace] updatingDict] valueForKey:ID];

	if (nil != updating)
	{
		return  [updating boolValue];
	}
	else
	{
		return NO;
	}
}

+ (BOOL) isUpdatingObjectNumberID:(NSNumber *)ID
{
	if (!CHECK_NUMBER(ID))
	{
		return NO;
	}
	
	return [self isUpdatingObjectStringID:[ID stringValue]];
}
@end
