//
//  NewCommentCell.m
//  Prototype
//
//  Created by Adrian Lee on 1/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TextFieldCell.h"

#import "ImageV.h"
#import "Util.h"
#import "TextInputer.h"

@interface TextFieldCell () <UITextViewDelegate, TextInputerDeletgate>
{
	UITextView *_inputView;
	UIViewController<NewCommentCellDelegate> *_deletegate;
	TextInputer *_inputer;
	UINavigationController *_navco;
}
@property (strong, nonatomic) UITextView *inputView;
@property (strong, nonatomic) TextInputer *inputer;
@property (strong, nonatomic) UINavigationController *navco;

@end

@implementation TextFieldCell

@synthesize inputView = _inputView;
@synthesize deletegate = _deletegate;
@synthesize inputer = _inputer;
@synthesize navco = _navco;

# pragma mark - life circle
- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	
	if (self) 
	{
	}
	return self;
}

- (void) setSelected:(BOOL)selected animated:(BOOL)animated
{
	[super setSelected:selected animated:animated];
	// Configure the view for the selected state
}

- (void) dealloc
{
	self.inputView = nil;
	self.deletegate = nil;
	self.inputer = nil;
	self.navco = nil;

	[super dealloc];
}

#pragma mark - draw cell

- (void) redrawInputView
{
	@autoreleasepool 
	{
		
		if (nil != self.inputView)
		{
			[self.inputView removeFromSuperview];
		}

		LOG(@"%f %f", self.self.contentView.frame.size.width, self.contentView.frame.size.height)
		self.inputView = [[[UITextView alloc] initWithFrame:self.contentView.frame] autorelease];
		ROUND_RECT(self.inputView.layer);
		self.inputView.backgroundColor = [Color milk];
		
		self.inputView.delegate = self;
		
		[self.contentView addSubview:self.inputView];
	}
}

- (void) redraw
{
	[self redrawInputView];
}

#pragma mark - UITextViewDelegate

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
	return YES;
}

#pragma mark - TextInputerDeletgate

- (void) textDoneWithTextInputer:(TextInputer *)inputer
{
	[self.deletegate dismissModalViewControllerAnimated:YES];
	[self.deletegate doneWithText:inputer.text.text];
}

- (void) cancelWithTextInputer:(TextInputer *)inputer
{
	[self.deletegate dismissModalViewControllerAnimated:YES];
}

@end
