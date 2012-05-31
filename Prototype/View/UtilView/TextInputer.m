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
const static CGFloat LABEL_FONT_SIZE = 12.0;

@interface TextInputer () <UITextViewDelegate>
{
	UITextView *_text;
	id<TextInputerDeletgate> _delegate;
	NSString *_sendButtonTitle;
	UILabel *_textCount;
	BOOL _drawCancel;
	BOOL _appearing;
	BOOL _acceptEmpty;
}

@property (strong, nonatomic) UILabel *textCount;

- (void) updateDoneButton;

@end

@implementation TextInputer

@synthesize text = _text;
@synthesize delegate = _delegate;
@synthesize sendButtonTitle = _sendButtonTitle;
@synthesize drawCancel = _drawCancel;
@synthesize appearing = _appearing;
@synthesize acceptEmpty = _acceptEmpty;
@synthesize textCount = _textCount;

#pragma mark - lifecycle

- (id) initWithNibName:(NSString *)nibNameOrNil 
		bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) 
	{
		self.sendButtonTitle = @"发送";
		self.drawCancel = YES;
		self.appearing = NO;
		self.acceptEmpty = NO;
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
	self.textCount = nil;
	
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

#pragma mark - GUI

- (void) back
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (void) initGUI
{
	@autoreleasepool 
	{
		// textview
		if (nil != self.text)
		{
			[self.text removeFromSuperview];
		}
		
		if (nil == self.text)
		{
			UIViewAutoresizing resize = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
			CGRect frame = self.view.frame;
			frame.origin = CGPointZero;
			self.text = [[[UITextView alloc] initWithFrame:frame] autorelease];
			self.text.font = [UIFont systemFontOfSize:FONT_SIZE];
			self.text.scrollEnabled = YES;
			self.text.scrollsToTop = YES;
			self.text.delegate = self;
			self.text.autoresizingMask = resize;
		}
		[self.view addSubview: self.text];
		
		// text count
		
		if (nil != self.textCount)
		{
			[self.textCount removeFromSuperview];
		}

		if (nil == self.textCount)
		{
			UIViewAutoresizing resize = UIViewAutoresizingFlexibleLeftMargin 
			| UIViewAutoresizingFlexibleTopMargin 
			| UIViewAutoresizingFlexibleWidth;
			self.textCount = [[[UILabel alloc] init] autorelease];
			self.textCount.font = [UIFont systemFontOfSize:LABEL_FONT_SIZE];
			self.textCount.autoresizingMask = resize;
			self.textCount.text = @"140";
			self.textCount.textColor = [UIColor grayColor];
			self.textCount.textAlignment = UITextAlignmentRight;
			[self.textCount sizeToFit];
		}
	
		[self repositionTextCount];
		
		// navigation bar
		self.navigationItem.rightBarButtonItem = SETUP_BAR_TEXT_BUTTON(self.sendButtonTitle, self, @selector(textDone:));
		self.navigationItem.rightBarButtonItem.enabled = NO;
		
		if (self.drawCancel)
		{
			self.navigationItem.leftBarButtonItem = SETUP_BAR_TEXT_BUTTON(@"取消", self, @selector(cancelEdit:));
		}
		else 
		{
			self.navigationItem.leftBarButtonItem = SETUP_BACK_BAR_BUTTON(self, @selector(back));
		}
	}
}

- (void) updateDoneButton
{
	if ((0 >= self.text.text.length) && !self.acceptEmpty)
	{
		self.navigationItem.rightBarButtonItem.enabled = NO;
	}
	else
	{
		self.navigationItem.rightBarButtonItem.enabled = YES;
	}
}

- (void) repositionTextCount
{
	CGSize size = self.textCount.frame.size;
	CGRect frame = self.textCount.frame;
	
	frame.origin.x = self.text.frame.size.width - size.width - LABEL_FONT_SIZE;
	frame.origin.y = self.text.frame.size.height - size.height - LABEL_FONT_SIZE;
	
	[self.textCount removeFromSuperview];
	self.textCount.frame = frame;
	[self.view addSubview:self.textCount];
}

- (void) updateTextCount
{
	NSString *textCount = [[NSString alloc] initWithFormat:@"%d", MAX_TEXT_LENGTH - self.text.text.length];
	self.textCount.text = textCount;
	[self.textCount sizeToFit];

	[textCount release];
}

#pragma mark - View lifecycle

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

- (void) viewWillDisappear:(BOOL)animated
{
	// unregister for keyboard notifications while not visible.
	[[NSNotificationCenter defaultCenter] removeObserver:self name: UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name: UIKeyboardDidHideNotification object:nil];
}

- (void) viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	self.appearing = YES;
}

- (void) viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	
	self.appearing = NO;
}

- (void) viewDidLoad
{
	[self initGUI];
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
		[self updateTextCount];
	}
}

- (BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
	NSUInteger newLength = [textView.text length] + [text length] - range.length;
	
	return (newLength > MAX_TEXT_LENGTH) ? NO : YES;
}

#pragma mark - keyboard

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
	self.text.autoresizesSubviews = YES;
	self.text.frame = frame;
	[self repositionTextCount];
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
	[self repositionTextCount];
	[UIView commitAnimations];
}



@end
