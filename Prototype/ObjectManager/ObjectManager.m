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
	NSMutableDictionary *_responderDictForGet;
	NSMutableDictionary *_responderDictForCreate;
	NSMutableDictionary *_updatingDict;
	NSArray *_IDArray;
	NSDictionary *_createParams;
	NSDictionary *_updateParams;
}
@end

@implementation ObjectManager

@synthesize objectDict = _objectDict;
@synthesize responderDictForGet = _responderDictForGet;
@synthesize responderDictForCreate = _responderDictForCreate;
@synthesize updatingDict = _updatingDict;
@synthesize createParams = _createParams;
@synthesize updateParams = _updateParams;

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
			self.responderDictForGet = [[[NSMutableDictionary alloc] init] autorelease];
			self.responderDictForCreate = [[[NSMutableDictionary alloc] init] autorelease];
			self.updatingDict = [[[NSMutableDictionary alloc] init] autorelease];
		}
	}

	return self;
}

- (void) dealloc 
{
	self.objectDict = nil;
	self.responderDictForGet = nil;
	self.responderDictForCreate = nil;
	self.updatingDict = nil;
	self.createParams = nil;
	self.updateParams = nil;

	[super dealloc];
}

+ (id) getInstnace
{
	LOG(@"Error %@: need to implement in the sub class",  [self class]);
	return nil;
}

#pragma mark - save and restore

+ (void) saveTo:(NSMutableDictionary *)dict
{
	[dict setObject:[[self getInstnace] objectDict] 
		 forKey:[self description]];;
}

+ (void) restoreFrom:(NSDictionary *)dict
{
	@autoreleasepool 
	{
		NSMutableDictionary *objectDict = [dict objectForKey:[self description]];
		
		if (nil != objectDict)
		{
			[[self getInstnace] setObjectDict:objectDict];
		}
	}
}

+ (void) reset
{
	NSMutableDictionary *newEmptyDict = [[NSMutableDictionary alloc] init];
	
	[[self getInstnace] setObjectDict:newEmptyDict];
	
	[newEmptyDict release];
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

#pragma mark - updating flag interface

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

#pragma mark - class interface get objects

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

#pragma mark - class interface set objects

+ (void) setObject:(NSDictionary *)object withStringID:(NSString *)ID
{
	if (!CHECK_STRING(ID))
	{
		return;
	}

	[[[self getInstnace] objectDict] setValue:object forKey:ID];
	
	[[self getInstnace] checkAndPerformResponderWithID:ID];
}

+ (void) setObject:(NSDictionary *)object withNumberID:(NSNumber *)ID
{
	if (!CHECK_NUMBER(ID))
	{
		return;
	}
	
	[self setObject:object withStringID:[ID stringValue]];
	
}

#pragma mark - get method - handler

- (void) checkAndPerformResponderWithID:(NSString *)ID
{
	@autoreleasepool 
	{
		NSArray *responderArray;
		
		@synchronized (_responderDictForGet)
		{
			responderArray = [[self.responderDictForGet valueForKey:ID] retain];
			[self.responderDictForGet setValue:nil forKey:ID];
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
	@synchronized (_responderDictForGet)
	{
		NSArray *responderArray;
		
		for (NSString *ID in IDArray)
		{
			responderArray = [[self.responderDictForGet valueForKey:ID] retain];
			[self.responderDictForGet setValue:nil forKey:ID];
			
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

#pragma mark - get method - send

- (void) bindID:(NSString *)ID withResponder:(MessageResponder*)responder
{
	@synchronized (_responderDictForGet)
	{
		NSMutableArray *responderArray =  [self.responderDictForGet valueForKey:ID];
		
		if (nil == responderArray)
		{
			responderArray = [[NSMutableArray alloc] initWithObjects:responder, nil];
			[self.responderDictForGet setValue:responderArray forKey:ID];
			[responderArray release];
		}
		else
		{
			[responderArray addObject:responder];
		}
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

+ (void) sendObjectRequest:(NSDictionary *)request withStringID:(NSString *)ID
{
	if (!CHECK_STRING(ID))
	{
		return;
	}
	
	if (NO == [self isUpdatingObjectStringID:ID])
	{
		[self markUpdatingStringID:ID];
		[request setValue:ID  forKey:@"params"];
		
		SEND_MSG_AND_BIND_HANDLER_WITH_PRIOIRY(request, 
						       [self getInstnace], 
						       @selector(handlerForSingleResult:), 
						       NORMAL_PRIORITY);
	}
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

		SEND_MSG_AND_BIND_HANDLER_WITH_PRIOIRY(request, 
						       [self getInstnace], 
						       @selector(handlerForSingleResult:), 
						       NORMAL_PRIORITY);
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

			SEND_MSG_AND_BIND_HANDLER_WITH_PRIOIRY(request, [self getInstnace], @selector(handlerForArrayResult:), NORMAL_PRIORITY);
		}
		
		[checkedSet release];
	}
}

# pragma mark - get method - interface

- (NSString *) getMethod
{
	LOG(@"Error %@: need to implement in the sub class",  [self class]);
	return nil;
}

+ (void) requestObjectWithStringID:(NSString *)ID andHandler:(SEL)handler andTarget:(id)target
{
	if (CHECK_STRING(ID))
	{
		// bind handler
		[self bindStringID:ID withHandler:handler andTarget:target];	
		
		// then send message
		NSMutableDictionary *request = [[NSMutableDictionary alloc] init];
		
		[request setValue:[[self getInstnace] getMethod] forKey:@"method"];
		
		[self sendObjectRequest:request withStringID:ID];
		
		[request release]; 
	}
}

+ (void) requestObjectWithNumberID:(NSNumber *)ID andHandler:(SEL)handler andTarget:(id)target
{
	if (CHECK_NUMBER(ID))
	{
		// bind handler
		[self bindNumberID:ID withHandler:handler andTarget:target];	

		// then send message
		NSMutableDictionary *request = [[NSMutableDictionary alloc] init];

		[request setValue:[[self getInstnace] getMethod] forKey:@"method"];

		[self sendObjectRequest:request withNumberID:ID];

		[request release];
	}
}

+ (void) requestObjectWithNumberIDArray:(NSArray *)numberIDArray
{	
	// no handler just send the message
	NSMutableDictionary *request = [[NSMutableDictionary alloc] init];

	[request setValue:[[self getInstnace] getMethod] forKey:@"method"];

	[self sendObjectArrayRequest:request withNumberIDArray:numberIDArray];

	[request release];
}

#pragma mark - create method - handler

- (void) checkAndPerformResponderForCreateWithMessageID:(NSString *)ID andResult:(id)result
{
	@autoreleasepool 
	{
		MessageResponder *responder;
		
		@synchronized (_responderDictForCreate)
		{
			responder = [[self.responderDictForCreate valueForKey:ID] retain];
			[self.responderDictForCreate setValue:nil forKey:ID];
			[responder autorelease];
		}
		
		if (nil != responder)
		{
			[responder performWithObject:result];
		}
	}
}

- (void) handlerForCreate:(id)result
{
	if (![result isKindOfClass: [NSDictionary class]])
	{
		LOG(@"Error handle non dict object");
		return;
	}
	
	NSString *messageID = [[result valueForKey:@"id"] stringValue];
	NSDictionary *objectDict = [result valueForKey:@"result"];
	NSString *objectID = [[objectDict valueForKey:@"id"] stringValue];
	
	[self.objectDict setValue:objectDict forKey:objectID];
	[self checkAndPerformResponderForCreateWithMessageID:messageID andResult:result];
}

#pragma mark - create method - send

- (void) bindCreateMessageID:(NSString *)ID withResponder:(MessageResponder*)responder
{
	
	@synchronized (_responderDictForCreate)
	{
		[self.responderDictForCreate setValue:responder forKey:ID];
	}
}

+ (void) bindCreateMessageID:(NSString *)ID WithHandler:(SEL)handler andTarget:(id)target
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
		[[self getInstnace] bindCreateMessageID:ID withResponder:responder];
		
		[responder release];
	}
}

#pragma mark - create method interfaces

- (NSString *) createMethod
{
	LOG(@"Error %@: need to implement in the sub class",  [self class]);
	return nil;
}

+ (NSInteger) createObjectWithHandler:(SEL)handler andTarget:(id)target
{
	NSMutableDictionary *request = [[NSMutableDictionary alloc] init];
	
	[request setValue:[[self getInstnace] createMethod] forKey:@"method"];

	[request setValue:[[self getInstnace] createParams] forKey:@"params"];
	
	NSInteger ID = GET_MSG_ID();
	NSString *messageID = [[NSString alloc] initWithFormat:@"%u", ID];
	
	// bind the handler first
	[self bindCreateMessageID:messageID WithHandler:handler andTarget:target];
	
	LOG(@"create = %@", request);
	
	// then send the request 
	SEND_MSG_AND_BIND_HANDLER_WITH_PRIOIRY_AND_ID(request, 
						      [self getInstnace], 
						      @selector(handlerForCreate:), 
						      NORMAL_PRIORITY,
						      ID);

	[messageID release];
	[request release];
	
	return ID;
}

#pragma mark - update method handler

- (void) checkAndPerformResponderForUpdateWithMessageID:(NSString *)ID andResult:(id)result
{
	@autoreleasepool 
	{
		MessageResponder *responder;
		
		@synchronized (_responderDictForCreate)
		{
			responder = [[self.responderDictForGet valueForKey:ID] retain];
			[self.responderDictForGet setValue:nil forKey:ID];
			[responder autorelease];
		}
		
		if (nil != responder)
		{
			[responder performWithObject:result];
		}
	}
}


- (void) handlerForUpate:(id)result
{
	if (![result isKindOfClass: [NSDictionary class]])
	{
		LOG(@"Error handle non dict object");
		return;
	}
	
	NSString *messageID = [[result valueForKey:@"id"] stringValue];
	NSDictionary *objectDict = [result valueForKey:@"result"];
	NSString *objectID = [[objectDict valueForKey:@"id"] stringValue];
	
	[self.objectDict setValue:objectDict forKey:objectID];
	[self checkAndPerformResponderForUpdateWithMessageID:messageID andResult:result];
}

#pragma mark - update method - send

- (void) bindUpdateMessageID:(NSString *)ID withResponder:(MessageResponder*)responder
{
	
	@synchronized (_responderDictForCreate)
	{
		[self.responderDictForGet setValue:responder forKey:ID];
	}
}

+ (void) bindUpdateMessageID:(NSString *)ID WithHandler:(SEL)handler andTarget:(id)target
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
		[[self getInstnace] bindUpdateMessageID:ID withResponder:responder];
		
		[responder release];
	}
}

#pragma mark - update method interfaces

- (NSString *) updateMethod
{
	LOG(@"Error %@: need to implement in the sub class",  [self class]);
	return nil;
}

+ (NSInteger) updateObjectWithhandler:(SEL)handler andTarget:(id)target
{
	NSMutableDictionary *request = [[NSMutableDictionary alloc] init];
	
	[request setValue:[[self getInstnace] updateMethod] forKey:@"method"];
	
	[request setValue:[[self getInstnace] updateParams] forKey:@"params"];	
	
	NSInteger ID = GET_MSG_ID();
	NSString *messageID = [[NSString alloc] initWithFormat:@"%u", ID];
	
	// bind the handler first
	[self bindCreateMessageID:messageID WithHandler:handler andTarget:target];
	
	// then send the request 
	SEND_MSG_AND_BIND_HANDLER_WITH_PRIOIRY_AND_ID(request, 
						      [self getInstnace], 
						      @selector(handlerForCreate:), 
						      NORMAL_PRIORITY,
						      ID);
	
	[messageID release];
	[request release];
	
	return ID;
}

@end
