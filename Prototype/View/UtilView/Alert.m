//
//  Alert.m
//  Prototype
//
//  Created by Adrian Lee on 5/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Alert.h"

CGFloat PADING_BOTTOM = 10.0;
CGFloat CONTENT_PADDING  = 5.0;

@interface Alert ()
{
	NSString *_messageText;
}

@end

@implementation Alert

@synthesize messageText = _messageText;

@synthesize message;

#pragma mark - custom xib object

DEFINE_CUSTOM_XIB(Alert, 0);

- (void) resetupXIB:(id)xibInstance
{
	[xibInstance initGUI];
}

#pragma mark - life circle

- (void) dealloc 
{
	self.messageText = nil;

	[message release];
	[super dealloc];
}

#pragma mark - GUI

- (void) initGUI
{
	ROUND_RECT(self.layer);
}

- ( void) resize
{
	[self.message sizeToFit];
	
	CGRect frame = self.message.frame;
	CGRect messageFrame = self.message.frame;
	
	messageFrame.origin.x = CONTENT_PADDING;
	messageFrame.origin.y = CONTENT_PADDING;
	
	self.message.frame = messageFrame;
	
	frame.size.width += CONTENT_PADDING * 2;
	frame.size.height += CONTENT_PADDING * 2;
	
	
	if (nil != self.superview)
	{
		frame.origin.x = self.superview.frame.size.width / 2 - frame.size.width / 2;
	}
	
	self.frame = frame;
}

- (void) setMessageText:(NSString *)messageText
{
	if (CHECK_EQUAL(_messageText, messageText))
	{
		return;
	}
	
	self.message.text = messageText;
	
	[self resize];
}

- (void) showIn:(UIView *)view
{
	if (nil != self.superview)
	{
		[self removeFromSuperview];
	}
	
	CGRect frame = self.frame;

	frame.origin.x = view.frame.size.width / 2 - frame.size.width / 2;
	frame.origin.y = view.frame.size.height - PADING_BOTTOM - frame.size.height;

	self.frame = frame;

	[view addSubview:self];
	[view bringSubviewToFront:self];
}

- (void) showInCenter:(UIView *)view
{
	if (nil != self.superview)
	{
		[self removeFromSuperview];
	}
	
	CGRect frame = self.frame;
	
	frame.origin.x = view.frame.size.width / 2 - frame.size.width / 2;
	frame.origin.y = view.frame.size.height / 2 - frame.size.height / 2;
	
	self.frame = frame;
	
	[view addSubview:self];
	[view bringSubviewToFront:self];
}

- (void) dismiss
{
	[self removeFromSuperview];
}

@end
