//
//  Util.m
//  Prototype
//
//  Created by Adrian Lee on 12/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Util.h"

#import "SDNetworkActivityIndicator.h"
#import "Message.h"

void SEND_MSG_AND_BIND_HANDLER(NSDictionary *messageDict, id target, SEL handler)
{
	SEND_MSG_AND_BIND_HANDLER_WITH_PRIOIRY(messageDict, target, handler, NORMAL_PRIORITY);
}

void START_NETWORK_INDICATOR(void)
{
	[[SDNetworkActivityIndicator sharedActivityIndicator] startActivity];
}

void STOP_NETWORK_INDICATOR(void)
{
	[[SDNetworkActivityIndicator sharedActivityIndicator] stopActivity];
}