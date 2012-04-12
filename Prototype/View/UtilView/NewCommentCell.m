//
//  NewCommentCell.m
//  Prototype
//
//  Created by Adrian Lee on 1/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NewCommentCell.h"

#import "ImageV.h"
#import "Util.h"
#import "LoginManager.h"
#import "ProfileMananger.h"
#import "TextInputer.h"

const static CGFloat AVATOR_SIZE = 44;
const static CGFloat FONT_SIZE = 15.0;
const static CGFloat PADING1 = 13.0; // padding from left cell border
const static CGFloat PADING2 = 10.0; // padding between element horizontal and from right boder
const static CGFloat PADING3 = 15.0; // padding from top virtical boder
const static CGFloat PADING4 = 9.0; // padding between element virtical and bottom border

@interface NewCommentCell () <UITextFieldDelegate, TextInputerDeletgate>
{
	UITextField *_inputView;
	ImageV *_avatorImageV;
	UIViewController<NewCommentCellDelegate> *_deletegate;
	TextInputer *_inputer;
	UINavigationController *_navco;
}
@property (strong, nonatomic) ImageV *avatorImageV;
@property (strong, nonatomic) UITextField *inputView;
@property (strong, nonatomic) TextInputer *inputer;
@property (strong, nonatomic) UINavigationController *navco;
@end

@implementation NewCommentCell

@synthesize avatorImageV = avatorImageV;
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
	self.avatorImageV = nil;
	self.inputView = nil;
	self.deletegate = nil;
	self.inputer = nil;
	self.navco = nil;

	[super dealloc];
}

#pragma mark - draw cell

- (void) getUserProfile
{
	NSDictionary *userProfile = [ProfileMananger getObjectWithNumberID:GET_USER_ID()];
	
	if (nil == userProfile)
	{
		[ProfileMananger requestObjectWithNumberID:GET_USER_ID() andHandler:@selector(getUserProfile) andTarget:self];
		
		return;
	}
	
	self.avatorImageV.picID = [userProfile valueForKey:@"avatar"];
}

- (void) getLoginUserInfo
{	
	NSNumber * loginUserID = [GET_USER_ID() retain];
	
	if (nil == loginUserID)
	{
		[LoginManager requestWithHandler:@selector(getLoginUserInfo) andTarget:self];
		
		return;
	}
	
	[self getUserProfile];
	
	[loginUserID release];
}

- (void) redrawImageV
{
	@autoreleasepool 
	{
		if (nil != self.avatorImageV)
		{
			[self.avatorImageV removeFromSuperview];
		}
		
		self.avatorImageV = [[[ImageV alloc] initWithFrame:CGRectMake(PADING1 * PROPORTION(), 
									      PADING3 * PROPORTION(), 
									      AVATOR_SIZE * PROPORTION(), 
									      AVATOR_SIZE * PROPORTION())] 
				     autorelease];
		
		[self.contentView addSubview:self.avatorImageV];
		
		[self getLoginUserInfo];
	}
}

- (void) redrawInputView
{
	@autoreleasepool 
	{
		
		if (nil != self.inputView)
		{
			[self.inputView removeFromSuperview];
		}
		
		CGFloat X = PADING1 + AVATOR_SIZE + PADING2;
		CGFloat Y = PADING3;
		CGFloat width = self.contentView.frame.size.width - ((X + PADING2) * PROPORTION());
		CGFloat height = AVATOR_SIZE;
		
		self.inputView = [[[UITextField alloc] init] autorelease];
		self.inputView.frame = CGRectMake(X * PROPORTION(),
						  Y * PROPORTION(),
						  width,
						  height * PROPORTION());
		
		self.inputView.delegate = self;
		self.inputView.backgroundColor = [Color whiteColor];
		
		
		[self.contentView addSubview:self.inputView];
	}
}

- (void) redraw
{
	[self redrawImageV];
	[self redrawInputView];
}

#pragma mark - UITextViewDelegate

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
	@autoreleasepool 
	{
		if (nil == self.inputer)
		{
			self.inputer = [[[TextInputer alloc] init] autorelease];
			self.inputer.delegate = self;
		}
		
		if (nil == self.navco)
		{
			self.navco = [[[UINavigationController alloc] initWithRootViewController:self.inputer] autorelease];
			self.navco.navigationBar.barStyle = UIBarStyleBlack;
			self.inputer.title = @"添加评论";
		}

		[self.deletegate presentModalViewController:self.navco animated:YES];
		[self.deletegate dismissModalViewControllerAnimated:YES];
	}
	
	return NO;
}

#pragma mark - TextInputerDeletgate

- (void) textDoneWithTextInputer:(TextInputer *)inputer
{
	[self.deletegate dismissModalViewControllerAnimated:YES];
	[self.deletegate sendCommentWithText:inputer.text.text];
	
}

- (void) cancelWithTextInputer:(TextInputer *)inpter
{
	[self.deletegate dismissModalViewControllerAnimated:YES];
}

@end
