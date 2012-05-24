//
//  BackgroundManager.m
//  Prototype
//
//  Created by Adrian Lee on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BackgroundManager.h"

#import "Message.h"
#import "Util.h"
#import "ImageManager.h"
#import "ProfileMananger.h"

@interface BackgroundManager ()
{
	NSDate *_lastRefeshDate;
	BOOL _isRefreshing;
}

@property (strong, nonatomic) NSDate *lastRefeshDate;
@property (assign, nonatomic) BOOL isRefreshing;

@end

static NSString *gs_fake_refresh_ID;
static NSString *gs_fake_set_ID;

@implementation BackgroundManager

@synthesize lastRefeshDate = _lastRefeshDate;
@synthesize isRefreshing = _isRefreshing;

#pragma mark - singleton

DEFINE_SINGLETON(BackgroundManager);

#pragma mark - life circle

- (id) init
{
	self = [super init];
	
	if (nil != self)
	{
		self.isRefreshing = NO;
		gs_fake_set_ID = [@"gs_fake_set_ID" retain];
		gs_fake_refresh_ID = [@"gs_fake_refresh_ID" retain];
	}
	
	return self;
}

- (void) dealloc
{
	self.lastRefeshDate = nil;
	
	[gs_fake_refresh_ID release];
	gs_fake_refresh_ID = nil;
	[gs_fake_set_ID release];
	gs_fake_set_ID = nil;
	
	[super dealloc];
}

#pragma mark - handler

- (void) refreshHandler:(id)result
{
	if (![result isKindOfClass: [NSDictionary class]])
	{
		LOG(@"Error handle non dict object");
		return;
	}
	
	for (NSDictionary *image in [result objectForKey:@"result"]) 
	{
		NSNumber *imageID = [image valueForKey:@"id"];
		
		[self.objectDict setValue:imageID forKey:[imageID stringValue]];
		[ImageManager setObject:image withNumberID:imageID];
	}
	
	self.lastRefeshDate = [NSDate date];
	
	[self checkAndPerformResponderWithID:gs_fake_refresh_ID];
}

- (void) setBackgroundHandler:result
{
	if (![result isKindOfClass: [NSDictionary class]])
	{
		LOG(@"Error handle non dict object");
		return;
	}
	
	NSDictionary *user = [result valueForKey:@"result"];
	
	if (nil != user)
	{
		[ProfileMananger setObject:user withNumberID:[user valueForKey:@"id"]];
	}
	
	[self checkAndPerformResponderWithID:gs_fake_set_ID];
}

#pragma mark - class interface

+ (void) refreshWith:(SEL)handler and:(id)target
{
	[self bindStringID:gs_fake_refresh_ID withHandler:handler andTarget:target];
	
	if ([[self getInstnace] isRefreshing])
	{
		return;
	}
	
	[self reset];
	
	NSDictionary *message =  [[NSDictionary alloc] 
				  initWithObjectsAndKeys:@"sys.get_bg_pics", 
				  @"method", 
				  nil];
	
	SEND_MSG_AND_BIND_HANDLER_WITH_PRIOIRY(message, 
					       [self getInstnace], 
					       @selector(refreshHandler:), 
					       NORMAL_PRIORITY);
	
	[message release];
}

+ (BOOL) isRefreshing
{
	return [[self getInstnace] isRefreshing];
}

+ (NSDate *) lastRefreshDate
{
	return [[self getInstnace] lastRefeshDate];
}

+ (NSInteger) count
{
	return [[[[self getInstnace] objectDict] allKeys] count];
}

+ (NSNumber *) backgroundFor:(NSInteger)index
{
	@autoreleasepool 
	{
		NSString *key = [[[[self getInstnace] objectDict]allKeys] objectAtIndex:index];

		return [[[self getInstnace] objectDict] valueForKey:key];
	}
}

+ (void) setBackground:(NSNumber *)imageID with:(SEL)handler and:(id)target
{
	[self bindStringID:gs_fake_set_ID withHandler:handler andTarget:target];
	
	
	NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:
				imageID, @"bg_pic", 
				nil];
	NSDictionary *message =  [[NSDictionary alloc] initWithObjectsAndKeys:
				  @"user.update", @"method",
				  params, @"params",
				  nil];
	
	SEND_MSG_AND_BIND_HANDLER_WITH_PRIOIRY(message, 
					       [self getInstnace], 
					       @selector(setBackgroundHandler:), 
					       NORMAL_PRIORITY);
	
	
	[message release];
	[params release];
}

@end
