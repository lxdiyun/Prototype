//
//  Created by Adrian Lee on 12/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LoginManager.h"

#import "Util.h"
#import "Message.h"

static NSString *gs_fakeLoginStringID;

@implementation LoginManager

#pragma mark - life circle

- (id) init
{
	self = [super init];
	
	if(nil != self)
	{
		// init data
		if (nil == gs_fakeLoginStringID)
		{
			gs_fakeLoginStringID = [[NSString alloc] initWithFormat:@"%d", 0x1];
		}
	}
	
	return self;
}

- (void) dealloc
{
	gs_fakeLoginStringID = nil;
	[super dealloc];
}

#pragma mark - singleton

DEFINE_SINGLETON(LoginManager);

+ (void) request
{
	@autoreleasepool 
	{
		if (YES == [self isUpdatingObjectStringID:gs_fakeLoginStringID])
		{
			return;
		}
		[self markUpdatingStringID:gs_fakeLoginStringID];
		
		NSMutableDictionary *params =  [[[NSMutableDictionary alloc] init] autorelease];
		NSMutableDictionary *request =  [[[NSMutableDictionary alloc] init] autorelease];

		// TODO update to real login user information
		[params setValue:@"wuvist" forKey:@"username"];
		[params setValue:@"dc6670b66d02cb02990e65272a936f36d25598d4" forKey:@"pwd"];

		[request setValue:@"sys.login" forKey:@"method"];
		[request setValue:params forKey:@"params"];

		SEND_MSG_AND_BIND_HANDLER_WITH_PRIOIRY(request, 
						       gs_shared_instance, 
						       @selector(handlerForResult:), 
						       HIGHEST_PRIORITY);
	}
}

+ (void) requestWithHandler:(SEL)handler andTarget:(id)target
{	
	[self bindStringID:gs_fakeLoginStringID withHandler:handler andTarget:target];
	
	[self request];
}

- (void) handlerForResult:(id)result
{
	if (![result isKindOfClass: [NSDictionary class]])
	{
		LOG(@"Error handle non dict object");
		return;
	}
	
	// TODO handle login failed message
	SET_USER_ID([result valueForKey:@"result"]);
	
	[[self class] cleanUpdatingStringID:gs_fakeLoginStringID];
	
	[self performSelector:@selector(checkAndPerformResponderWithID:) withObject:gs_fakeLoginStringID];

	START_PING();
}

@end
