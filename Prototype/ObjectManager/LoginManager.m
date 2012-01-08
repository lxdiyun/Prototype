//
//  LoginMessage.m
//  Prototype
//
//  Created by Adrian Lee on 12/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LoginManager.h"

#import "Util.h"
#import "Message.h"

@implementation LoginManager

DEFINE_SINGLETON(LoginManager);

+ (void) request
{
	@autoreleasepool 
	{
		NSMutableDictionary *params =  [[[NSMutableDictionary alloc] init] autorelease];
		NSMutableDictionary *request =  [[[NSMutableDictionary alloc] init] autorelease];

		// TODO update to real login user information
		[params setValue:@"wuvist" forKey:@"username"];
		[params setValue:@"dc6670b66d02cb02990e65272a936f36d25598d4" forKey:@"pwd"];

		[request setValue:@"sys.login" forKey:@"method"];
		[request setValue:params forKey:@"params"];

		SEND_MSG_AND_BIND_HANDLER_WITH_PRIOIRY(request, 
						       self, 
						       @selector(handler:), 
						       HIGHEST_PRIORITY);
	}
}

+ (void) handler:(id)dict
{
	if (![dict isKindOfClass: [NSDictionary class]])
	{
		LOG(@"Error handle non dict object");
		return;
	}
	
	// TODO handle login failed message
	SET_USER_ID([dict valueForKey:@"result"]);

	START_PING();
}

@end
