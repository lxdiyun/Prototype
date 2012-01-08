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

+ (ObjectManager *) getInstnace
{
	LOG(@"Error should not get here");
	return nil;
}

#pragma mark - message handler

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
	[self.updatingDict setValue:[NSNumber numberWithBool:NO] forKey:objectID];
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
		[self.updatingDict setValue:[NSNumber numberWithBool:NO] forKey:objectID];
		[newObjectArray addObject:objectID];
	}
	
	[self checkAndPerformResponderWithStringIDArray:newObjectArray];
	[newObjectArray release];

}

#pragma mark - message request

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

- (void) markUpdatingStringID:(NSString *)ID
{
	[self.updatingDict setValue:[NSNumber numberWithBool:YES] forKey:ID];
}

- (void) requestObjectWithRequest:(NSDictionary *)request
{
	SEND_MSG_AND_BIND_HANDLER_WITH_PRIOIRY(request, self, @selector(handlerForSingleResult:), NORMAL_PRIORITY);
}

- (void) requestObjectArrayWithRequest:(NSDictionary *)request
{
	SEND_MSG_AND_BIND_HANDLER_WITH_PRIOIRY(request, self, @selector(handlerForArrayResult:), NORMAL_PRIORITY);
}

#pragma mark - interface

+ (NSDictionary *) getObjectWithStringID:(NSString *)ID
{
	return [[[self getInstnace] objectDict] valueForKey:ID];
}

+ (NSDictionary *) getObjectWithNumberID:(NSNumber *)ID
{
	return [self getObjectWithStringID:[ID stringValue]];
}

+ (void) bindStringID:(NSString *)ID withHandler:(SEL)handler andTarget:(id)target
{
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

+ (void) sendObjectRequest:(NSDictionary *)request
{
	[[self getInstnace] requestObjectWithRequest:request];
}

+ (void) sendObjectArrayRequest:(NSDictionary *)request
{
	[[self getInstnace] requestObjectArrayWithRequest:request];
}

+ (void) markUpdatingStringID:(NSString *)ID
{
	[[self getInstnace] markUpdatingStringID:ID];
}

+ (void) markUpdatingNumberID:(NSNumber *)ID
{
	[self markUpdatingStringID:[ID stringValue]];
}

+ (void) markUpdatingNumberIDArray:(NSArray *)IDArray
{
	for (NSNumber *ID in IDArray)
	{
		[self markUpdatingNumberID:ID];
	}
}

+ (BOOL) isUpdatingObjectStringID:(NSString *)ID
{
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
	return [self isUpdatingObjectStringID:[ID stringValue]];
}
@end
