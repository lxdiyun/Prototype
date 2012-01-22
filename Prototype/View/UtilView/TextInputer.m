//
//  TextInputer.m
//  Prototype
//
//  Created by Adrian Lee on 1/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TextInputer.h"
#import "Util.h"

const static CGFloat FONT_SIZE = 15.0;

@interface TextInputer () <UITextViewDelegate>
{
	UITextView *_text;
	id<TextInputerDeletgate> _delegate;
	NSString *_sendButtonTitle;
	BOOL _drawCancel;
}
@end

@implementation TextInputer

@synthesize text = _text;
@synthesize delegate = _delegate;
@synthesize sendButtonTitle = _sendButtonTitle;
@synthesize drawCancel = _drawCancel;

#pragma mark - lifecycle

- (id) initWithNibName:(NSString *)nibNameOrNil 
		bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) 
	{
		self.sendButtonTitle = @"发送";
		self.drawCancel = YES;
	}
	return self;
}

- (void) didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

- (void) dealloc
{
	self.text = nil;
	
	[super dealloc];
}

#pragma mark - button handler

- (void) cancelEdit:(id)sender
{
	[self.delegate cancelWithTextInputer:self];
}

- (void) textDone:(id)sender
{
	if (0 < self.text.text.length)
	{
		[self.delegate textDoneWithTextInputer:self];
		self.text.text = nil;
		self.navigationItem.rightBarButtonItem.enabled = NO;
	}
	else
	{
		[self cancelEdit:self];
	}
}

#pragma mark - View draw

- (void) redraw
{
	@autoreleasepool 
	{
		if (nil != self.text)
		{
			[self.text removeFromSuperview];
		}
		
		
		self.text = [[[UITextView alloc] init] autorelease];
		self.text.font = [UIFont systemFontOfSize:FONT_SIZE * PROPORTION()];
		self.text.delegate = self;

		self.view = self.text;
		
		self.view.autoresizesSubviews = YES;
		
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] 
							   initWithTitle:self.sendButtonTitle 
							   style:UIBarButtonItemStyleDone 
							   target:self 
							   action:@selector(textDone:)] autorelease];
		
		self.navigationItem.rightBarButtonItem.enabled = NO;
		
		if (self.drawCancel)
		{
			self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] 
								  initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
								  target:self 
								  action:@selector(cancelEdit:)] 
								 autorelease];
		}
	}
}

#pragma mark - View lifecycle

- (void) loadView
{
	[self redraw];
}

- (void) viewWillAppear:(BOOL)animated
{
	[self.text becomeFirstResponder];

	[super viewWillAppear:animated];
}

- (void) viewDidUnload
{
	self.text = nil;
	[super viewDidUnload];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UITextViewDelegate

- (void) textViewDidChange:(UITextView *)textView
{
	if (self.text == textView)
	{
		NSString *textString  = self.text.text;
		
		if (0 < textString.length)
		{
			self.navigationItem.rightBarButtonItem.enabled = YES;
		}
		else
		{
			self.navigationItem.rightBarButtonItem.enabled = NO;
		}
	}
}

@end
