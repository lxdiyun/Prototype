//
//  Created by Adrian Lee on 12/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "EventManager.h"

#import "Util.h"
#import "Message.h"
#import "ImageManager.h"

static NSString *gs_fakeEventID = nil;

@implementation EventManager

#pragma mark - singleton

DEFINE_SINGLETON(EventManager);

#pragma mark - life circle

- (id) init 
{
	self = [super init];
	
	if (nil != self) 
	{
		if (nil == gs_fakeEventID)
		{
			gs_fakeEventID = [[NSString alloc] initWithFormat:@"%d", 0x1];
		}
	}
	
	return self;
}

- (void) dealloc
{
	gs_fakeEventID = nil;
	[super dealloc];
}

#pragma mark - overwrite super class

- (void) messageHandler:(id)dict withListID:(NSString *)ID
{
	[super messageHandler:dict withListID:ID];
	
	NSDictionary *messageDict = [(NSDictionary*)dict retain];
	NSMutableArray *newPicArray = [[NSMutableArray alloc] init];
	
	for (NSDictionary *object in [messageDict objectForKey:@"result"]) 
	{
		NSNumber *picID = [[object valueForKey:@"obj"] valueForKey:@"pic"];
		if (nil == [ImageManager getObjectWithNumberID:picID])
		{
			[newPicArray addObject:picID];
		}

	}
	
	// buffer the new image info
	[ImageManager requestImageWithNumberIDArray:newPicArray];
	
	[newPicArray release];
	[messageDict release];
}

#pragma mark - send request message

- (void) setGetMethodForRequest:(NSMutableDictionary *)request
{
	[request setValue:@"event.get" forKey:@"method"];
}

-(void) sendRequestNewerWithCount:(uint32_t)count
{
	NSMutableDictionary *request = [[NSMutableDictionary alloc] init];
	NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
	uint32_t newestKey = [self getNewestKeyWithID:gs_fakeEventID];
	
	[self setGetMethodForRequest:request];
	
	if (0 < newestKey)
	{
		[self setParms:params withCursor:newestKey count:count forward:NO];
	}
	else
	{
		[self setParms:params withCursor:-1 count:count forward:YES];
	}
	
	[request setValue:params forKey:@"params"];
	
	NSString *messageID = [[NSString alloc] initWithFormat:@"%u", SEND_MSG_AND_BIND_HANDLER(request, self, @selector(messageDispatcher:))];
	
	[self bindMessageID:messageID withListID:[gs_fakeEventID intValue] withType:REQUEST_NEWER];
	
	[messageID release];
	[params release];
	[request release];
}

-(void) sendRequestOlderWithCount:(uint32_t)count
{
	NSMutableDictionary *request = [[NSMutableDictionary alloc] init];
	NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
	uint32_t oldestKey = [self getOldestKeyWithID:gs_fakeEventID];
	
	[self setGetMethodForRequest:request];
	
	if (0 < oldestKey)
	{
		[self setParms:params withCursor:oldestKey count:count forward:YES];
		[request setValue:params forKey:@"params"];
		
		
	}
	else
	{
		[self setParms:params withCursor:-1 count:count forward:YES];
	}
	
	NSString *messageID = [[NSString alloc] initWithFormat:@"%u", SEND_MSG_AND_BIND_HANDLER(request, self, @selector(messageDispatcher:))];
	
	[self bindMessageID:messageID withListID:[gs_fakeEventID intValue] withType:REQUEST_OLDER];
	
	[messageID release];
	[params release];
	[request release];
}

#pragma mark - interface

+ (void) requestNewerCount:(uint32_t)count withHandler:(SEL)handler andTarget:(id)target
{
	if (NO == [[self getInstnace] requestUpdateWith:REQUEST_NEWER withID:gs_fakeEventID])
	{
		return;
	}

	// bind target
	[[self getInstnace] bindMessageType:REQUEST_NEWER 
				     withListID:gs_fakeEventID 
				withHandler:handler 
				  andTarget:target];

	// then send request
	[[self getInstnace] sendRequestNewerWithCount:count];
}

+ (void) requestOlderCount:(uint32_t)count withHandler:(SEL)handler andTarget:(id)target
{
	if (0 >= [[self getInstnace] getOldestKeyWithID:gs_fakeEventID])
	{
		[self requestNewerCount:count withHandler:handler andTarget:target];
		return;
	}
	if (NO == [[self getInstnace] requestUpdateWith:REQUEST_OLDER withID:gs_fakeEventID])
	{
		return;
	}

	// bind target
	[[self getInstnace] bindMessageType:REQUEST_OLDER withListID:gs_fakeEventID withHandler:handler andTarget:target ];

	// then send request
	[[self getInstnace] sendRequestOlderWithCount:count];
}

+ (NSArray *) eventKeyArray
{
	return [[[self getInstnace] objectKeyArrayDict] valueForKey:gs_fakeEventID]; 
}

+ (BOOL) isNewerUpdating
{
	@autoreleasepool 
	{
		return [[self getInstnace] isUpatringWithType:REQUEST_NEWER withListID:gs_fakeEventID];
	}
}

+ (NSDate *)lastUpdatedDate
{
	return [[[self getInstnace] lastUpdatedDateDict] valueForKey:gs_fakeEventID];
}

+ (NSDictionary *) getObjectWithStringID:(NSString *)objectID
{
	return [[self getInstnace] getObject:objectID inList:gs_fakeEventID];
}

@end
