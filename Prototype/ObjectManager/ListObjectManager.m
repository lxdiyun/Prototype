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

#pragma mark - object in list
- (id) getObject:(NSString *)objectID inList:(NSString *)listID;
{
	return [[self.objectDict valueForKey:listID] valueForKey:objectID];
}


#pragma mark - updating flag

- (NSMutableDictionary *) getTypeUpdatingDict:(MESSAGE_TYPE)type
{
	NSString *typeString = [[[NSString alloc] initWithFormat:@"%d", type] autorelease];
	
	NSMutableDictionary *typeDict = [self.updatingDict valueForKey:typeString];
	if (nil == typeDict)
	{
		
		typeDict = [[[NSMutableDictionary alloc] init] autorelease];
		[self.updatingDict setValue:typeDict forKey:typeString];
	}
	
	return typeDict;
}

- (void) markUpdatingWithType:(MESSAGE_TYPE)type withListID:(NSString *)ID
{
	@autoreleasepool 
	{
		NSMutableDictionary *typeDict = [self getTypeUpdatingDict:type];
		[typeDict setValue:[NSNumber numberWithBool:YES] forKey:ID];
	}
}

- (void) cleanUpdatingWithType:(MESSAGE_TYPE)type withListID:(NSString *)ID
{
	@autoreleasepool 
	{
		NSMutableDictionary *typeDict = [self getTypeUpdatingDict:type];
		[typeDict setValue:[NSNumber numberWithBool:NO] forKey:ID];
		
	}
}

- (BOOL) isUpatringWithType:(MESSAGE_TYPE)type withListID:(NSString *)ID
{
	@autoreleasepool 
	{
		NSMutableDictionary *typeDict = [self getTypeUpdatingDict:type];
		NSNumber *updating = [typeDict valueForKey:ID];
		
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

- (BOOL) requestUpdateWith:(MESSAGE_TYPE)type withID:(NSString *)ID
{
	@synchronized (self)
	{
		if (YES == [self isUpatringWithType:type withListID:ID])
		{
			return NO;
		}
		
		[self markUpdatingWithType:type withListID:ID];
		
		return YES;
	}
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


#pragma mark - message request

- (void ) setParms:(NSMutableDictionary*)params 
	withCursor:(int32_t)cursor 
	     count:(uint32_t)count 
	   forward:(BOOL)forward
{	
	[params setValue:[NSNumber numberWithInteger:cursor] forKey:@"cursor"];
	[params setValue:[NSNumber numberWithInteger:count] forKey:@"count"];
	[params setValue:[NSNumber numberWithBool:forward] forKey:@"forwarding"];
}

- (uint32_t) getNewestKeyWithID:(NSString *)ID
{
	int32_t objectKey;
	
	NSArray *keyArray = [self.objectKeyArrayDict valueForKey:ID];
	
	objectKey = [[keyArray objectAtIndex:0] integerValue];
	
	return objectKey;
}

- (uint32_t) getOldestKeyWithID:(NSString *)ID
{
	int32_t objectKey;
	
	NSArray *keyArray = [self.objectKeyArrayDict valueForKey:ID];
	
	objectKey = [[keyArray lastObject] integerValue];
	
	return objectKey;
}

@end
