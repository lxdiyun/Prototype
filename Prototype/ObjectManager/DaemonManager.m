//
//  DaemonManager.m
//  Prototype
//
//  Created by Adrian Lee on 5/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DaemonManager.h"

#import "Util.h"
#import "Message.h"

@interface DaemonManager ()
{
	NSMutableDictionary *_daemonResponders;
}

@property (strong, nonatomic) NSMutableDictionary *daemonResponders;

@end

@implementation DaemonManager

@synthesize daemonResponders = _daemonResponders;

#pragma mark - single ton

DEFINE_SINGLETON(DaemonManager);

#pragma mark - life circle

- (id) init
{
	self = [super init];
	
	if (nil != self)
	{
		[self bindDaemonDispatcher];
		
		if (nil == self.daemonResponders)
		{
			NSMutableDictionary *daemonResponders = [[NSMutableDictionary alloc] init];
			
			self.daemonResponders = daemonResponders;
			
			[daemonResponders release];
		}
	}
	
	return self;
}

#pragma mark - dispatcher

- (void) bindDaemonDispatcher
{
	MessageResponder *responder = [[MessageResponder alloc] init];
	
	responder.handler = @selector(daemonMessageDispatcher:);
	responder.target = self;
	
	ADD_MESSAGE_RESPONDER(responder, DEAMON_MESSAGE_RESEVERED);
	
	[responder release];
}

- (void) daemonMessageDispatcher:(id)message
{
	NSString *method = [message valueForKey:@"method"];
	
	if (nil != method)
	{
		MessageResponder *reponder = [self.daemonResponders valueForKey:method];
		
		if (nil != reponder)
		{
			[reponder performWithObject:message];
		}
	}
}

#pragma mark - register

+ (void) registerDaemon:(NSString *)method with:(SEL)handler and:(id)target
{
	if (CHECK_STRING(method) && (nil != handler) && (nil != target))
	{
		MessageResponder *responder = [[MessageResponder alloc] init];
		
		responder.handler = handler;
		responder.target = target;
		
		[[[self getInstnace] daemonResponders] setValue:responder forKey:method];
		
		[responder release];
	}
}

@end
