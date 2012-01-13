//
//  Created by Adrian Lee on 01/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ListObjectManager.h"

#import "Util.h"
#import "Message.h"
#import "ImageManager.h"

// Auxiliary class
@interface Handler : NSObject
@property (assign) MESSAGE_TYPE type;
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
@property (retain) NSMutableDictionary *messageDict;
@end

@implementation ListObjectManager

@synthesize objectDict = _objectDict;
@synthesize responderArrayDict = _responderArrayDict;
@synthesize updatingDict = _updatingDict;
@synthesize objectKeyArrayDict = _objectKeyArrayDict;
@synthesize lastUpdatedDateDict = _lastUpdatedDateDict;
@synthesize messageDict = _messageDict;


#pragma mark - singleton

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
	
	[super dealloc];
}


+ (id) getInstnace
{
	LOG(@"Error should use the subclass method");
	return nil;
}

#pragma mark - object in list

+ (id) getObject:(NSString *)objectID inList:(NSString *)listID
{
	if (!CHECK_STRING(listID))
	{
		return nil;	
	}
	
	return [[[[self getInstnace] objectDict] valueForKey:listID] valueForKey:objectID];
}

#pragma mark - updating flag

+ (NSMutableDictionary *) getTypeUpdatingDict:(MESSAGE_TYPE)type
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

+ (void) markUpdatingWithType:(MESSAGE_TYPE)type withListID:(NSString *)listID
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

- (void) cleanUpdatingWithType:(MESSAGE_TYPE)type withListID:(NSString *)ID
{
	@autoreleasepool 
	{
		NSMutableDictionary *typeDict = [[self class] getTypeUpdatingDict:type];
		[typeDict setValue:[NSNumber numberWithBool:NO] forKey:ID];
		
	}
}

+ (BOOL) isUpdatingWithType:(MESSAGE_TYPE)type withListID:(NSString *)listID
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

+ (BOOL) requestUpdateWith:(MESSAGE_TYPE)type withListID:(NSString *)listID
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
+ (NSDate *)lastUpdatedDateForList:(NSString *)listID
{
	if (!CHECK_STRING(listID))
	{
		return nil;	
	}

	return [[[self getInstnace] lastUpdatedDateDict] valueForKey:listID];
}

#pragma mark - resoponder

- (NSMutableDictionary *) getTypeResponderArrayDictWithType:(MESSAGE_TYPE)type
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

- (void) checkAndPerformResponderWithType:(MESSAGE_TYPE)type withListID:(NSString *)ID;
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
				[responder perform];
			}
		}
	}
}

- (void) bindResponderWithType:(MESSAGE_TYPE)type 
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

- (void) bindMessageType:(MESSAGE_TYPE)type withListID:(NSString *)ID withHandler:(SEL)handler andTarget:(id)target
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

#pragma mark message handler dict

- (void) bindMessageID:(NSString *)messageID withListID:(uint32_t)listID withType:(MESSAGE_TYPE)type 
{
	Handler *handler = [[Handler alloc] init];
	handler.type = type;
	handler.listID = listID;
	
	[self.messageDict setValue:handler forKey:messageID];
	[handler release];
}

#pragma mark - message handler

- (void) messageHandler:(id)dict withListID:(NSString *)ID
{
	
	NSDictionary *messageDict = [(NSDictionary*)dict retain];
	
	NSDictionary *listDict = [self.objectDict valueForKey:ID];
	
	if (nil == listDict)
	{
		listDict = [[NSMutableDictionary alloc] init];
		[self.objectDict setValue:listDict forKey:ID];
		[listDict autorelease];
	}
	
	for (NSDictionary *object in [messageDict objectForKey:@"result"]) 
	{
		[listDict setValue:object forKey:[[object valueForKey:@"id"] stringValue]];
	}
	
	// update object key array
	[self.objectKeyArrayDict setValue:[[listDict allKeys] 
					   sortedArrayUsingFunction:ID_SORTER 
					   context:nil] 
				   forKey:ID];
	
	[messageDict release];
}

- (void) handlerForType:(MESSAGE_TYPE)type withDict:(id)dict withID:(NSString *)ID
{
	[self messageHandler:dict withListID:ID];
	
	[self checkAndPerformResponderWithType:type withListID:ID];
	
	[self cleanUpdatingWithType:type withListID:ID];
	
	if (REQUEST_NEWER == type)
	{
		NSDate *date =  [NSDate date];
		
		[self.lastUpdatedDateDict setValue:date forKey:ID];
	}
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


#pragma mark - message request get method

- (NSString *) getMethod
{
	LOG(@"Error should use the subclass method");
	return nil;
}

- (void) setGetMethodParams:(NSMutableDictionary *)params forList:(NSString *)listID
{
	LOG(@"Error should use the subclass method");
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

- (uint32_t) getNewestKeyWithlistID:(NSString *)ID
{
	uint32_t objectKey = 0;
	
	NSArray *keyArray = [self.objectKeyArrayDict valueForKey:ID];
	
	if (0 < keyArray.count)
	{
		objectKey = [[keyArray objectAtIndex:0] integerValue];
	}
	
	return objectKey;
}

- (uint32_t) getOldestKeyWithlistID:(NSString *)ID
{
	uint32_t objectKey = 0;
	
	NSArray *keyArray = [self.objectKeyArrayDict valueForKey:ID];
	
	if (0 < keyArray.count)
	{
		objectKey = [[keyArray lastObject] integerValue];
	}
	
	return objectKey;
}


-(void) sendRequestNewerWithCount:(uint32_t)count withListID:(NSString *)listID
{
	NSMutableDictionary *request = [[NSMutableDictionary alloc] init];
	NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
	uint32_t newestKey = [self getNewestKeyWithlistID:listID];
	
	// this will call the sub class method
	[request setValue:[self getMethod] forKey:@"method"];
	[self setGetMethodParams:params forList:listID];
	
	if (0 < newestKey)
	{
		[self setParms:params withCursor:newestKey count:count forward:NO];
	}
	else
	{
		[self setParms:params withCursor:-1 count:count forward:YES];
	}
	
	[request setValue:params forKey:@"params"];
	
	NSString *messageID = [[NSString alloc] 
			       initWithFormat:@"%u", 
			       SEND_MSG_AND_BIND_HANDLER_WITH_PRIOIRY(request, 
								      self, 
								      @selector(messageDispatcher:), 
								      NORMAL_PRIORITY)];
	
	[self bindMessageID:messageID withListID:[listID intValue] withType:REQUEST_NEWER];
	
	[messageID release];
	[params release];
	[request release];
}

-(void) sendRequestOlderWithCount:(uint32_t)count withListID:(NSString *)listID
{
	NSMutableDictionary *request = [[NSMutableDictionary alloc] init];
	NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
	uint32_t oldestKey = [self getOldestKeyWithlistID:listID];
	
	// this will call the sub class method
	[request setValue:[self getMethod] forKey:@"method"];
	[self setGetMethodParams:params forList:listID];
	
	if (0 < oldestKey)
	{
		[self setParms:params withCursor:oldestKey count:count forward:YES];
		[request setValue:params forKey:@"params"];
		
		
	}
	else
	{
		[self setParms:params withCursor:-1 count:count forward:YES];
	}
	
	NSString *messageID = [[NSString alloc] 
			       initWithFormat:@"%u", 
			       SEND_MSG_AND_BIND_HANDLER_WITH_PRIOIRY(request, 
								      self, 
								      @selector(messageDispatcher:), 
								      NORMAL_PRIORITY)];
	
	[self bindMessageID:messageID withListID:[listID intValue] withType:REQUEST_OLDER];
	
	[messageID release];
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
	
	if (0 >= [[self getInstnace] getOldestKeyWithlistID:listID])
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

#pragma mark - key array

+ (NSArray *) keyArrayForList:(NSString *)listID
{
	if (!CHECK_STRING(listID))
	{
		return nil;	
	}

	return [[[self getInstnace] objectKeyArrayDict] valueForKey:listID]; 
}

@end
