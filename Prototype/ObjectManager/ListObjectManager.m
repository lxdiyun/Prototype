//
//  Created by Adrian Lee on 01/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ListObjectManager.h"

#import "Util.h"
#import "Message.h"
#import "ImageManager.h"

// object Manager
const static uint16_t OBJECT_SAVE_TO_CACHE = 20;

// Auxiliary class
@interface Handler : NSObject
@property (assign) LIST_OBJECT_MESSAGE_TYPE type;
@property (assign) uint32_t listID;
@end

@implementation Handler
@synthesize type;
@synthesize listID;
@end

@interface ListObjectManager () 
{
	NSMutableDictionary *_objectDict;
	NSMutableDictionary *_responderArrayDict;
	NSMutableDictionary *_updatingDict;
	NSMutableDictionary *_objectKeyArrayDict;
	NSMutableDictionary *_messageDict;
	NSDictionary *_lastUpdatedDateDict;
	NSArray *_IDArray;
}

@property (strong) NSMutableDictionary *responderArrayDict;
@property (strong) NSMutableDictionary *updatingDict;
@property (strong) NSMutableDictionary *messageDict;
@end

@implementation ListObjectManager

@synthesize objectDict = _objectDict;
@synthesize responderArrayDict = _responderArrayDict;
@synthesize updatingDict = _updatingDict;
@synthesize objectKeyArrayDict = _objectKeyArrayDict;
@synthesize lastUpdatedDateDict = _lastUpdatedDateDict;
@synthesize messageDict = _messageDict;

// C.R.U.D
@synthesize createMethodString;
@synthesize getMethodString;
@synthesize updateMethodString;
@synthesize deleteMethodString;

#pragma mark - life circle

- (id) init
{
	self = [super init];
	
	if (nil != self)
	{
		@autoreleasepool 
		{
			self.objectDict = [[[NSMutableDictionary alloc] init] autorelease];
			self.responderArrayDict = [[[NSMutableDictionary alloc] init] autorelease];
			self.updatingDict = [[[NSMutableDictionary alloc] init] autorelease];
			self.objectKeyArrayDict = [[[NSMutableDictionary alloc] init] autorelease];
			self.lastUpdatedDateDict = [[[NSMutableDictionary alloc] init] autorelease];
			self.messageDict = [[[NSMutableDictionary alloc] init] autorelease];
			
			self.createMethodString = nil;
			self.getMethodString = nil;
			self.updateMethodString = nil;
			self.deleteMethodString = nil;
		}
	}
	
	return self;
}

- (void) dealloc 
{
	self.objectDict = nil;
	self.responderArrayDict = nil;
	self.updatingDict = nil;
	self.objectKeyArrayDict = nil;
	self.lastUpdatedDateDict = nil;
	self.messageDict = nil;
	
	self.createMethodString = nil;
	self.getMethodString = nil;
	self.updateMethodString = nil;
	self.deleteMethodString = nil;
	
	[super dealloc];
}

+ (id) getInstnace
{
	LOG(@"%@: Error should use the subclass method", [self class]);
	return nil;
}

#pragma mark - save and restore

+ (void) saveTo:(NSMutableDictionary *)dict;
{	
	NSDictionary *allObject = [[self getInstnace] objectDict];
	NSMutableDictionary *topAllObject = [[NSMutableDictionary alloc] init];
	
	for (NSString *listID in [allObject allKeys])
	{
		NSMutableDictionary *topObject = [[NSMutableDictionary alloc] init];
		NSDictionary *listObjectDict = [allObject valueForKey:listID];
		NSArray *keyArray = [self keyArrayForList:listID];
		
		for (int i = 0; (i < OBJECT_SAVE_TO_CACHE) && i < keyArray.count; ++i)
		{
			NSString *key = [keyArray objectAtIndex:i];
			[topObject setValue:[listObjectDict valueForKey:key] forKey:key];
		}
		
		[topAllObject setValue:topObject forKey:listID];
		
		[topObject release];
	}

	[dict setObject:topAllObject forKey:[self description]];
	[topAllObject release];
}

+ (void) restoreFrom:(NSMutableDictionary *)dict
{
	@autoreleasepool {
		NSMutableDictionary *objectDict = [dict objectForKey:[self description]];
		
		if (nil != objectDict)
		{
			[[self getInstnace] setObjectDict:objectDict];
			for (NSString *key in [objectDict allKeys]) 
			{
				[[self getInstnace] updateKeyArrayForList:key withResult:nil forward:NO];
			}
		}
	}
	
}

+ (void) reset
{
	NSMutableDictionary *newEmptyDict = [[NSMutableDictionary alloc] init];
	NSMutableDictionary *emptyKeyArrayDict = [[NSMutableDictionary alloc] init];

	[[self getInstnace] setObjectDict:newEmptyDict];
	[[self getInstnace] setObjectKeyArrayDict:emptyKeyArrayDict];
	
	[newEmptyDict release];
	[emptyKeyArrayDict release];
}

#pragma mark - key array

- (void) updateKeyArrayForList:(NSString *)listID withResult:(NSArray *)result forward:(BOOL)forward;
{
	NSDictionary *listDict = [self.objectDict valueForKey:listID];
	
	if (nil != listDict)
	{
		[self.objectKeyArrayDict setValue:[[listDict allKeys] 
						   sortedArrayUsingFunction:ID_SORTER 
						   context:nil] 
					   forKey:listID];
	}
}

+ (NSArray *) keyArrayForList:(NSString *)listID
{
	if (!CHECK_STRING(listID))
	{
		return nil;	
	}
	
	return [[[self getInstnace] objectKeyArrayDict] valueForKey:listID]; 
}


- (NSInteger) newestCursorWithlistID:(NSString *)listID
{
	NSInteger objectKey = 0;
	
	NSArray *keyArray = [self.objectKeyArrayDict valueForKey:listID];
	
	if (0 < keyArray.count)
	{
		objectKey = [[keyArray objectAtIndex:0] integerValue];
	}
	
	return objectKey;
}

- (NSInteger) cursorForObject:(NSString *)objectID inlist:(NSString *)listID
{
	return [objectID integerValue];
}

- (NSInteger) oldestCursorWithlistID:(NSString *)listID
{
	NSInteger objectKey = 0;
	
	NSArray *keyArray = [self.objectKeyArrayDict valueForKey:listID];
	
	if (0 < keyArray.count)
	{
		objectKey = [[keyArray lastObject] integerValue];
	}
	
	return objectKey;
}


+ (NSInteger) oldestKeyForList:(NSString *)listID
{
	return [[self getInstnace] oldestCursorWithlistID:listID];
}

+ (NSInteger) newestKeyForList:(NSString *)listID
{
	return [[self getInstnace] newestCursorWithlistID:listID];
}

#pragma mark - object in list

+ (id) getObject:(NSString *)objectID inList:(NSString *)listID
{
	if (!CHECK_STRING(listID))
	{
		return nil;	
	}
	
	// refresh object from server
	[self requestMiddle:objectID inListID:listID andCount:1 withHandler:nil andTarget:nil];
	
	return [[[[self getInstnace] objectDict] valueForKey:listID] valueForKey:objectID];
}

+ (void) setObject:(NSDictionary *)object 
      withStringID:(NSString *)objectID 
	    inList:(NSString *)listID
{
	if (!CHECK_STRING(listID))
	{
		return;	
	}
	
	if (!CHECK_STRING(objectID))
	{
		return;
	}
	
	[[[[self getInstnace] objectDict] valueForKey:listID] setValue:object 
								forKey:objectID];
}

#pragma mark - updating flag

+ (NSMutableDictionary *) getTypeUpdatingDict:(LIST_OBJECT_MESSAGE_TYPE)type
{
	NSString *typeString = [[[NSString alloc] initWithFormat:@"%d", type] autorelease];
	
	NSMutableDictionary *typeDict = [[[self getInstnace] updatingDict] valueForKey:typeString];
	if (nil == typeDict)
	{
		
		typeDict = [[[NSMutableDictionary alloc] init] autorelease];
		[[[self getInstnace] updatingDict] setValue:typeDict forKey:typeString];
	}
	
	return typeDict;
}

+ (void) markUpdatingWithType:(LIST_OBJECT_MESSAGE_TYPE)type withListID:(NSString *)listID
{
	if (!CHECK_STRING(listID))
	{
		return;	
	}

	@autoreleasepool 
	{
		NSMutableDictionary *typeDict = [self getTypeUpdatingDict:type];
		[typeDict setValue:[NSNumber numberWithBool:YES] forKey:listID];
	}
}

- (void) cleanUpdatingWithType:(LIST_OBJECT_MESSAGE_TYPE)type withListID:(NSString *)ID
{
	@autoreleasepool 
	{
		NSMutableDictionary *typeDict = [[self class] getTypeUpdatingDict:type];
		[typeDict setValue:[NSNumber numberWithBool:NO] forKey:ID];
		
	}
}

+ (BOOL) isUpdatingWithType:(LIST_OBJECT_MESSAGE_TYPE)type withListID:(NSString *)listID
{
	if (!CHECK_STRING(listID))
	{
		return NO;	
	}

	@autoreleasepool 
	{
		NSMutableDictionary *typeDict = [self getTypeUpdatingDict:type];
		NSNumber *updating = [typeDict valueForKey:listID];
		
		if (nil != updating)
		{
			return  [updating boolValue];
		}
		else
		{
			return NO;
		}
	}
}

+ (BOOL) requestUpdateWith:(LIST_OBJECT_MESSAGE_TYPE)type withListID:(NSString *)listID
{
	if (!CHECK_STRING(listID))
	{
		return NO;	
	}

	@synchronized (self)
	{
		if (YES == [self isUpdatingWithType:type withListID:listID])
		{
			return NO;
		}
		
		[self markUpdatingWithType:type withListID:listID];
		
		return YES;
	}
}

#pragma mark - update time

+ (NSDate *) lastUpdatedDateForList:(NSString *)listID
{
	if (!CHECK_STRING(listID))
	{
		return nil;	
	}

	return [[[self getInstnace] lastUpdatedDateDict] valueForKey:listID];
}

#pragma mark - resoponder

- (NSMutableDictionary *) getTypeResponderArrayDictWithType:(LIST_OBJECT_MESSAGE_TYPE)type
{
	NSString *typeString = [[[NSString alloc] initWithFormat:@"%d", type] autorelease];
	
	@synchronized (self.responderArrayDict)
	{
		NSMutableDictionary *responderDict = [self.responderArrayDict valueForKey:typeString];
		
		if (nil == responderDict)
		{
			responderDict = [[[NSMutableDictionary alloc] init] autorelease];
			[self.responderArrayDict setValue:responderDict forKey:typeString];
		}
		
		return responderDict;
	}
}

- (void) checkAndPerformResponderWithType:(LIST_OBJECT_MESSAGE_TYPE)type 
			       withListID:(NSString *)ID 
				forResult:(NSDictionary *)result;
{
	@autoreleasepool 
	{
		NSMutableDictionary *typeDict = [self getTypeResponderArrayDictWithType:type];
		NSArray *responderArray = nil;
		
		@synchronized (typeDict)
		{
			responderArray = [[typeDict valueForKey:ID] retain];
			[typeDict setValue:nil forKey:ID];
			[responderArray autorelease];
		}
		
		if (nil != responderArray)
		{
			for (MessageResponder *responder in responderArray)
			{
				[responder performWithObject:result];
			}
		}
	}
}

- (void) bindResponderWithType:(LIST_OBJECT_MESSAGE_TYPE)type 
		    withListID:(NSString *)ID 
		 withResponder:(MessageResponder *)responder
{
	@autoreleasepool 
	{
		NSMutableDictionary *typeDict = [self getTypeResponderArrayDictWithType:type];
		NSMutableArray *responderArray = nil;
		
		@synchronized (typeDict)
		{
			responderArray = [typeDict valueForKey:ID];
			
			if (nil == responderArray)
			{
				responderArray = [[NSMutableArray alloc] initWithObjects:responder, nil];
				[typeDict setValue:responderArray forKey:ID];
				[responderArray release];
			}
			else
			{
				[responderArray addObject:responder];
			}
		}
	}
}

- (void) bindMessageType:(LIST_OBJECT_MESSAGE_TYPE)type 
	      withListID:(NSString *)ID 
	     withHandler:(SEL)handler 
	       andTarget:(id)target
{
	if ((nil != handler) && (nil != target))
	{
		MessageResponder *responder = [[MessageResponder alloc] init];
		
		responder.handler = handler;
		responder.target = target;
		
		[self bindResponderWithType:type withListID:ID withResponder:responder];
		
		[responder release];
	}
}

#pragma mark message handler dictionary

- (void) handlerForType:(LIST_OBJECT_MESSAGE_TYPE)type withDict:(id)dict withID:(NSString *)ID
{	
	switch (type) 
	{
		case REQUEST_NEWER:
		{
			NSDate *date =  [NSDate date];
			
			[self.lastUpdatedDateDict setValue:date forKey:ID];
			
			[self getMethodHandler:dict withListID:ID forward:NO];
		}
			break;
		case REQUEST_MIDDLE:
		case REQUEST_OLDER:
			[self getMethodHandler:dict withListID:ID forward:YES];
			break;
		case LIST_OBJECT_CREATE:
			[self createMethodHanlder:dict withListID:ID];
			break;
		case LIST_OBJECT_UPDATE:
			[self updateMethodHandler:dict withListID:ID];
		default:
			break;
	}
	
	[self checkAndPerformResponderWithType:type withListID:ID forResult:dict];
	
	[self cleanUpdatingWithType:type withListID:ID];
}

- (void) messageDispatcher:(id)dict
{
	// TODO add error handling
	if (![dict isKindOfClass: [NSDictionary class]])
	{
		LOG(@"Receive Error Message %@:", dict);
		return;
	}
	
	NSString *messageID = [[dict valueForKey:@"id"] stringValue];
	Handler * handler = [self.messageDict valueForKey: messageID];
	
	if (nil != handler)
	{
		NSString *ID = [[NSString alloc] initWithFormat:@"%d", handler.listID];
		
		[self handlerForType:handler.type withDict:dict withID:ID];
		
		[ID release];
	}
}

- (void) bindMessageID:(NSString *)messageID withListID:(uint32_t)listID withType:(LIST_OBJECT_MESSAGE_TYPE)type 
{
	Handler *handler = [[Handler alloc] init];
	handler.type = type;
	handler.listID = listID;
	
	[self.messageDict setValue:handler forKey:messageID];
	[handler release];
}

#pragma mark - get method handler

- (void) getMethodHandler:(id)result withListID:(NSString *)listID forward:(BOOL)forward
{
	
	NSDictionary *messageDict = [(NSDictionary*)result retain];
	NSMutableArray *resultArray = [[NSMutableArray alloc] init];
	NSDictionary *listDict = [self.objectDict valueForKey:listID];
	
	if (nil == listDict)
	{
		listDict = [[NSMutableDictionary alloc] init];
		[self.objectDict setValue:listDict forKey:listID];
		[listDict autorelease];
	}
	
	for (NSDictionary *object in [messageDict objectForKey:@"result"]) 
	{
		[listDict setValue:object forKey:[[object valueForKey:@"id"] stringValue]];

		if (forward)
		{
			[resultArray addObject:object];
		}
		else
		{
			[resultArray insertObject:object atIndex:0];
		}
	}
	
	// update object key array
	[self updateKeyArrayForList:listID withResult:resultArray forward:forward];
	
	[messageDict release];
	[resultArray release];
}

#pragma mark - get method interface

- (void) configGetMethodParams:(NSMutableDictionary *)params 
			  forList:(NSString *)listID
{
	// default do nothing
}

- (void ) setParms:(NSMutableDictionary*)params 
	withCursor:(int32_t)cursor 
	     count:(uint32_t)count 
	   forward:(BOOL)forward
{	
	[params setValue:[NSNumber numberWithInteger:cursor] forKey:@"cursor"];
	[params setValue:[NSNumber numberWithInteger:count] forKey:@"count"];
	[params setValue:[NSNumber numberWithBool:forward] forKey:@"forwarding"];
}

- (void) sendRequestNewerWithCount:(uint32_t)count withListID:(NSString *)listID
{
	NSMutableDictionary *request = [[NSMutableDictionary alloc] init];
	NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
	uint32_t newestKey = [self newestCursorWithlistID:listID];
	
	// this will call the sub class method
	[request setValue:self.getMethodString forKey:@"method"];
	[self configGetMethodParams:params forList:listID];

	if (0 < newestKey)
	{
		[self setParms:params withCursor:newestKey count:count forward:NO];
	}
	else
	{
		[self setParms:params withCursor:-1 count:count forward:YES];
	}
	
	if (0 < params.count)
	{
		[request setValue:params forKey:@"params"];
	}
	
	uint32_t messageID = GET_MSG_ID();
	NSString *messageIDString = [[NSString alloc] initWithFormat:@"%u", messageID];
	
	// bind the handler
	[self bindMessageID:messageIDString withListID:[listID intValue] withType:REQUEST_NEWER];
	
	// then send
	SEND_MSG_AND_BIND_HANDLER_WITH_PRIOIRY_AND_ID(request, 
						      self, 
						      @selector(messageDispatcher:), 
						      NORMAL_PRIORITY,
						      messageID);
	
	
	[messageIDString release];
	[params release];
	[request release];
}

- (void) sendRequestMiddle:(NSString *)objectID 
		     withCount:(uint32_t)count 
		withListID:(NSString *)listID
{
	NSMutableDictionary *request = [[NSMutableDictionary alloc] init];
	NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
	
	// this will call the sub class method
	[request setValue:self.getMethodString forKey:@"method"];
	[self configGetMethodParams:params forList:listID];
	
	[self setParms:params 
	    withCursor:[self cursorForObject:objectID inlist:listID]
		 count:count 
	       forward:YES];
	
	if (0 < params.count)
	{
		[request setValue:params forKey:@"params"];
	}
	
	uint32_t messageID = GET_MSG_ID();
	NSString *messageIDString = [[NSString alloc] initWithFormat:@"%u", messageID];
	
	// bind the handler
	[self bindMessageID:messageIDString withListID:[listID intValue] withType:REQUEST_MIDDLE];
	
	// then send
	SEND_MSG_AND_BIND_HANDLER_WITH_PRIOIRY_AND_ID(request, 
						      self, 
						      @selector(messageDispatcher:), 
						      NORMAL_PRIORITY,
						      messageID);
	
	
	[messageIDString release];
	[params release];
	[request release];
}

- (void) sendRequestOlderWithCount:(uint32_t)count withListID:(NSString *)listID
{
	NSMutableDictionary *request = [[NSMutableDictionary alloc] init];
	NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
	uint32_t oldestKey = [self oldestCursorWithlistID:listID];
	
	// this will call the sub class method
	[request setValue:self.getMethodString forKey:@"method"];
	[self configGetMethodParams:params forList:listID];
	
	if (0 < oldestKey)
	{
		[self setParms:params withCursor:oldestKey count:count forward:YES];
	}
	else
	{
		[self setParms:params withCursor:-1 count:count forward:YES];
	}
	
	if (0 < params.count)
	{
		[request setValue:params forKey:@"params"];
	}
	
	uint32_t messageID = GET_MSG_ID();
	NSString *messageIDString = [[NSString alloc] initWithFormat:@"%u", messageID];
	
	// bind the handler
	[self bindMessageID:messageIDString withListID:[listID intValue] withType:REQUEST_OLDER];
	
	// then send
	SEND_MSG_AND_BIND_HANDLER_WITH_PRIOIRY_AND_ID(request, 
						      self, 
						      @selector(messageDispatcher:), 
						      NORMAL_PRIORITY,
						      messageID);
	
	
	[messageIDString release];
	[params release];
	[request release];
}

+ (void) requestNewerWithListID:(NSString *)listID 
		       andCount:(uint32_t)count 
		    withHandler:(SEL)handler 
		      andTarget:(id)target
{
	if (!CHECK_STRING(listID))
	{
		return;	
	}
	
	if (NO == [self requestUpdateWith:REQUEST_NEWER withListID:listID])
	{
		return;
	}
	
	// bind target
	[[self getInstnace] bindMessageType:REQUEST_NEWER 
				 withListID:listID 
				withHandler:handler 
				  andTarget:target];
	
	// then send request
	[[self getInstnace] sendRequestNewerWithCount:count withListID:listID];
}

+ (void) requestOlderWithListID:(NSString *)listID 
		       andCount:(uint32_t)count 
		    withHandler:(SEL)handler 
		      andTarget:(id)target
{
	if (!CHECK_STRING(listID))
	{
		return;	
	}
	
	if (0 >= [[self getInstnace] oldestCursorWithlistID:listID])
	{
		[self requestNewerWithListID:listID andCount:count withHandler:handler andTarget:target];
		return;
	}
	
	if (NO == [self requestUpdateWith:REQUEST_OLDER withListID:listID])
	{
		return;
	}
	
	// bind target
	[[self getInstnace] bindMessageType:REQUEST_OLDER withListID:listID withHandler:handler andTarget:target ];
	
	// then send request
	[[self getInstnace] sendRequestOlderWithCount:count withListID:listID];
}

+ (void) requestMiddle:(NSString *)objectID
	      inListID:(NSString *)listID 
	      andCount:(uint32_t)count 
	   withHandler:(SEL)handler 
	     andTarget:(id)target
{
	if (!CHECK_STRING(listID))
	{
		return;	
	}
	
	if (!CHECK_STRING(objectID))
	{
		return;
	}
	
	if (NO == [self requestUpdateWith:REQUEST_MIDDLE withListID:listID])
	{
		return;
	}
	
	// bind target
	[[self getInstnace] bindMessageType:REQUEST_MIDDLE withListID:listID withHandler:handler andTarget:target ];
	
	// then send request
	[[self getInstnace] sendRequestMiddle:objectID withCount:count withListID:listID];
}

#pragma mark create method - handler

- (void) createMethodHanlder:(id)result withListID:(NSString *)listID;
{
	NSDictionary *messageDict = [(NSDictionary*)result retain];
	NSMutableArray *resultArray = [[NSMutableArray alloc] init];
	NSDictionary *listDict = [self.objectDict valueForKey:listID];
	
	if (nil == listDict)
	{
		listDict = [[NSMutableDictionary alloc] init];
		[self.objectDict setValue:listDict forKey:listID];
		[listDict autorelease];
	}
	
	NSDictionary *object = [messageDict objectForKey:@"result"];

	[listDict setValue:object forKey:[[object valueForKey:@"id"] stringValue]];
	[resultArray insertObject:object atIndex:0];

	// update object key array
	[self updateKeyArrayForList:listID withResult:resultArray forward:NO];
	
	[messageDict release];
	[resultArray release];
}

#pragma mark - create method - request

- (void) configCreateMethodParams:(NSMutableDictionary *)params 
			forObject:(NSDictionary *)object
			   inList:(NSString *)listID
{
	[params addEntriesFromDictionary:object];
}

- (void) sendRequestCreateForObject:(NSDictionary *)newObject inList:(NSString *)listID
{
	NSMutableDictionary *request = [[NSMutableDictionary alloc] init];
	NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
	
	// this will call the sub class method
	[request setValue:self.createMethodString forKey:@"method"];
	[self configCreateMethodParams:params forObject:newObject inList:listID];
	
	if (0 < params.count)
	{
		[request setValue:params forKey:@"params"];
	}
	
	uint32_t messageID = GET_MSG_ID();
	NSString *messageIDString = [[NSString alloc] initWithFormat:@"%u", messageID];
	
	// bind the handler
	[self bindMessageID:messageIDString withListID:[listID intValue] withType:LIST_OBJECT_CREATE];
	
	// then send
	SEND_MSG_AND_BIND_HANDLER_WITH_PRIOIRY_AND_ID(request, 
						      self, 
						      @selector(messageDispatcher:), 
						      NORMAL_PRIORITY,
						      messageID);
	
	
	[messageIDString release];
	[params release];
	[request release];
}

+ (void) requestCreateWithObject:(NSDictionary *)newobject
			  inList:(NSString *)listID 
		     withHandler:(SEL)handler 
		       andTarget:(id)target
{
	if (!CHECK_STRING(listID))
	{
		return;	
	}
	
	// bind target
	[[self getInstnace] bindMessageType:LIST_OBJECT_CREATE 
				 withListID:listID 
				withHandler:handler 
				  andTarget:target];
	
	// then send request
	[[self getInstnace] sendRequestCreateForObject:newobject inList:listID];
}

#pragma mark update method - handler

- (void) updateMethodHandler:(id)result withListID:(NSString *)listID;
{
	NSDictionary *messageDict = [(NSDictionary*)result retain];
	NSMutableArray *resultArray = [[NSMutableArray alloc] init];
	NSDictionary *listDict = [self.objectDict valueForKey:listID];
	
	if (nil == listDict)
	{
		listDict = [[NSMutableDictionary alloc] init];
		[self.objectDict setValue:listDict forKey:listID];
		[listDict autorelease];
	}
	
	NSDictionary *object = [messageDict objectForKey:@"result"];
	
	[listDict setValue:object forKey:[[object valueForKey:@"id"] stringValue]];
	[resultArray insertObject:object atIndex:0];
	
	// update object key array
	[self updateKeyArrayForList:listID withResult:resultArray forward:NO];
	
	[messageDict release];
	[resultArray release];
}

#pragma mark - update method - request

- (void) configUpdateParams:(NSMutableDictionary *)params 
		  forObject:(NSDictionary *)object
		     inList:(NSString *)listID;
{
	[params addEntriesFromDictionary:object];
}

- (void) sendRequestUpdateForObject:(NSDictionary *)object 
			     inList:(NSString *)listID
{
	NSMutableDictionary *request = [[NSMutableDictionary alloc] init];
	NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
	
	// this will call the sub class method
	[request setValue:self.updateMethodString forKey:@"method"];
	[self configUpdateParams:params forObject:object inList:listID];
	
	if (0 < params.count)
	{
		[request setValue:params forKey:@"params"];
	}
	
	uint32_t messageID = GET_MSG_ID();
	NSString *messageIDString = [[NSString alloc] initWithFormat:@"%u", messageID];
	
	// bind the handler
	[self bindMessageID:messageIDString withListID:[listID intValue] withType:LIST_OBJECT_CREATE];
	
	// then send
	SEND_MSG_AND_BIND_HANDLER_WITH_PRIOIRY_AND_ID(request, 
						      self, 
						      @selector(messageDispatcher:), 
						      NORMAL_PRIORITY,
						      messageID);
	
	
	[messageIDString release];
	[params release];
	[request release];
}

+ (void) requestUpdateWithObject:(NSDictionary *)object 
			  inList:(NSString *)listID
		     withHandler:(SEL)handler
		       andTarget:(id)target
{
	if (!CHECK_STRING(listID))
	{
		return;	
	}
	
	// bind target
	[[self getInstnace] bindMessageType:LIST_OBJECT_CREATE 
				 withListID:listID 
				withHandler:handler 
				  andTarget:target];
	
	// then send request
	[[self getInstnace] sendRequestUpdateForObject:object inList:listID];
}

@end
