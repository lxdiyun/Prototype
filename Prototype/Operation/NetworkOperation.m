//
//  NetworkOperation.m
//  Prototype
//
//  Created by Adrian Lee on 12/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "NetworkOperation.h"

@interface NetworkOperation ()
{
@private
	id _target;
	SEL _action;
	SEL _callbackWhenFinish;
}

@end

@implementation NetworkOperation

- (id) initWithTarget:(id)target action:(SEL)action callbackWhenFinish:(SEL)callBack
{
	self = [super init];
	if (nil != self)
	{
		_target = target;
		_action = action;
		_callbackWhenFinish = callBack;
	}

	return self;
}

- (void)dealloc
{
	[super dealloc];
}

- (void)main
{
	if (nil != _target)
	{
		if (nil != _action)
		{
			if ([_target respondsToSelector:@selector(_action)])
			{
				[_target _action];
			}
		}

		if (nil != _callbackWhenFinish)
		{
			if ([_target respondsToSelector:@selector(_callbackWhenFinish)])
			{
				[_target performSelectorOnMainThread:_callbackWhenFinish 
							  withObject:nil
						       waitUntilDone:NO];     
			}
		}
	}

}

@end
