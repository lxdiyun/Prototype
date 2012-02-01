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
- (void) updateDoneButton;
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
	@autoreleasepool 
	{
		if (0 < self.text.text.length)
		{
			[self.delegate textDoneWithTextInputer:self];
			self.text.text = @"";
			[self updateDoneButton];
		}
		else
		{
			[self cancelEdit:self];
		}
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
		self.text.scrollEnabled = YES;
		self.text.scrollsToTop = YES;
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
}

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	if (0 >= self.text.text.length)
	{
		if (![self.text isFirstResponder])
		{
			[self.text becomeFirstResponder];
		}
	}
	else
	{
		if ([self.text isFirstResponder])
		{
			
			[self.text resignFirstResponder];
		}
	}
	
	[self updateDoneButton];
	
	// register for keyboard notifications
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (keyboardDidShow:)name: UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (keyboardDidHide:) name: UIKeyboardDidHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
	// unregister for keyboard notifications while not visible.
	[[NSNotificationCenter defaultCenter] removeObserver:self name: UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name: UIKeyboardDidHideNotification object:nil];
}

- (void) viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
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
		[self updateDoneButton];
	}
}

#pragma mark - interface and action

- (void) updateDoneButton
{
	if (0 < self.text.text.length)
	{
		self.navigationItem.rightBarButtonItem.enabled = YES;
	}
	else
	{
		self.navigationItem.rightBarButtonItem.enabled = NO;
	}
}

static CGFloat gs_txtPostContentHeight = 0;

-(void) keyboardDidShow: (NSNotification *)notif 
{
	NSDictionary *userInfo = [notif userInfo];
	NSValue* aValue;
	if (nil != &UIKeyboardFrameEndUserInfoKey)
	{
		aValue = [userInfo valueForKey:@"UIKeyboardFrameEndUserInfoKey"];
	}
	else
	{
		aValue = [userInfo valueForKey:@"UIKeyboardBoundsUserInfoKey"];
	}
	CGRect keyboardRect;

	[aValue getValue:&keyboardRect];
	
	CGFloat keyboardHeight;
	if (keyboardRect.size.height <= keyboardRect.size.width)
	{
		keyboardHeight = keyboardRect.size.height;
	}
	else
	{
		keyboardHeight = keyboardRect.size.width;
	}

	if (0 == gs_txtPostContentHeight)
	{
		gs_txtPostContentHeight = self.text.bounds.size.height;
	}

	CGRect frame = self.text.frame;

	frame.size.height = gs_txtPostContentHeight - keyboardHeight;
	
	self.text.frame = frame;
}

-(void) keyboardDidHide: (NSNotification *)notif 
{
	NSDictionary *userInfo = [notif userInfo];
	CGRect frame = self.text.frame;
	frame.size.height = gs_txtPostContentHeight;
	gs_txtPostContentHeight = 0;
	NSValue *animationDurationValue = [userInfo valueForKey:@"UIKeyboardAnimationDurationUserInfoKey"];
	NSTimeInterval animationDuration;
	[animationDurationValue getValue:&animationDuration];
	
	// Animate the resize of the text view's frame in sync with the keyboard's appearance.
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:animationDuration];
	self.text.frame = frame;
	[UIView commitAnimations];
}



@end
