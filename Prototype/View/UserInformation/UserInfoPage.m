//
//  UserInfoPage.m
//  Prototype
//
//  Created by Adrian Lee on 12/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "UserInfoPage.h"

#import "Util.h"
#import "ImageV.h"
#import "AvatarCell.h"
#import "LoginManager.h"
#import "ProfileMananger.h"
#import "PhotoSelector.h"
#import "ImageManager.h"
#import "TextInputer.h"
#import "Message.h"

const static CGFloat FONT_SIZE = 15.0;
const static CGFloat AVATOR_CELL_HEIGTH = 88.0;

typedef enum USER_INFO_SECTION_ENUM
{
	USER_DETAIL = 0x0,
	USER_AVATOR = 0x1,
	USER_INTRO = 0x2,
	USER_INFO_SECTION_MAX
} USER_INFO_SECTION;

typedef enum USER_DETAIL_ENUM
{
	USER_NAME = 0x0,
	USER_PLACE = 0x1,
	USER_DETAIL_MAX
} USER_DETAIL_TYPE;

static NSString *USER_DETAIL_TITLE[USER_DETAIL_MAX] = {@"名字：", @"所在地："};
static NSString *USER_AVATOR_TITLE = @"头像：";
static NSString *USER_INTRO_TITLE = @"个人介绍";

@interface  UserInfoPage   () <UITableViewDelegate, UITextFieldDelegate, PhototSelectorDelegate, UITextViewDelegate, TextInputerDeletgate>
{
	AvatarCell *_avatorCell;
	PhotoSelector *_photoSelector;
	UITextView *_introduceView;
	UITextField *_userDetailTextView[USER_DETAIL_MAX];
	UIBarButtonItem *_cancelButton;
	UIBarButtonItem *_saveButton;
	UIBarButtonItem *_editButton;
	UIBarButtonItem *_backButton;
	TextInputer *_textInputer;
}

@property (strong, nonatomic) UITextView *introduceView;
@property (assign, nonatomic) BOOL editable;
@property (strong, nonatomic) AvatarCell *avatorCell;
@property (strong, nonatomic) PhotoSelector *photoSelector;
@property (strong, nonatomic) UIBarButtonItem *cancelButton;
@property (strong, nonatomic) UIBarButtonItem *saveButton;
@property (strong, nonatomic) UIBarButtonItem *editButton;
@property (strong, nonatomic) UIBarButtonItem *backButton;
@property (strong, nonatomic) TextInputer *textInputer;


- (void) initViewDisplay;
- (void) sendUserInfoRequest;
- (void) forceUpdateUserInfo;
@end

@implementation UserInfoPage

@synthesize introduceView = _introduceView;
@synthesize editable;
@synthesize avatorCell = _avatorCell;
@synthesize photoSelector = _photoSelector;
@synthesize cancelButton = _cancelButton;
@synthesize saveButton = _sendButton;
@synthesize editButton = _editButton;
@synthesize backButton = _backButton;
@synthesize textInputer = _textInputer;

#pragma mark - singleton

DEFINE_SINGLETON(UserInfoPage);

#pragma mark - life circle

- (id) initWithStyle:(UITableViewStyle)style
{
	self = [super initWithStyle:UITableViewStyleGrouped];
	if (nil != self) 
	{
	}
	return self;
}

- (void) didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void) cleanData
{
	self.editable = NO;
	
	for (int i = 0; i < USER_DETAIL_MAX; ++i)
	{
		[_userDetailTextView[i] release];
		_userDetailTextView[i] = nil;
	}
	

	self.editButton = nil;
	self.saveButton = nil;
	self.cancelButton = nil;
	self.introduceView = nil;
	self.photoSelector = nil;
	self.avatorCell = nil;
	self.backButton = nil;
	self.textInputer = nil;
}

- (void) viewDidLoad
{
	[super viewDidLoad];

	[self cleanData];
	
	[self initViewDisplay];
	
	[self sendUserInfoRequest];
}

- (void) back
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (void) initViewDisplay
{
	@autoreleasepool 
	{
		[self setTitle:@"个人设置"];
		self.photoSelector = [[[PhotoSelector alloc] init] autorelease];
		
		if (nil == self.editButton)
		{
			self.editButton = SETUP_BAR_TEXT_BUTTON(@"编辑", self, @selector(startEditUserInfo:));
		}
		
		self.navigationItem.rightBarButtonItem = self.editButton;
		
		self.backButton = SETUP_BACK_BAR_BUTTON(self, @selector(back));
		self.navigationItem.leftBarButtonItem = self.backButton;
		
		for (int i = 0; i < USER_DETAIL_MAX; ++i)
		{
			
			if (nil == _userDetailTextView[i])	
			{
				_userDetailTextView[i] = [[UITextField alloc] init];
				_userDetailTextView[i].font = [UIFont boldSystemFontOfSize:FONT_SIZE * PROPORTION()];
				_userDetailTextView[i].delegate = self;
				_userDetailTextView[i].contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
				_userDetailTextView[i].returnKeyType = UIReturnKeyDone;
			}
		}
		
		if (nil == self.avatorCell) 
		{
			AvatarCell *cell = [[AvatarCell alloc] initWithStyle:UITableViewCellStyleValue2 
							      reuseIdentifier:USER_AVATOR_TITLE];
			cell.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, AVATOR_CELL_HEIGTH * PROPORTION());
			[cell redraw];
			cell.textLabel.textColor = [Color grey2];
			cell.textLabel.font = [UIFont systemFontOfSize:13.0];
			cell.textLabel.text = USER_AVATOR_TITLE;
			
			self.avatorCell =  cell;
			
			[cell release];
		}
		
		if (nil == self.introduceView)
		{
			UITextView *textView;
			
			textView = [[UITextView alloc] init];
			textView.scrollEnabled = NO;
			textView.backgroundColor = [UIColor clearColor];
			textView.font = [UIFont boldSystemFontOfSize:FONT_SIZE * PROPORTION()];
			textView.delegate = self;
			textView.editable = NO;
			textView.userInteractionEnabled = NO;
			
			self.introduceView = textView;
			
			[textView release];
		}
	}
}

- (void) viewDidUnload
{
	[self cleanData];
	
	[self forceUpdateUserInfo];
	
	[super viewDidUnload];
}

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];

	[self.tableView reloadData];
}

- (void) viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void) viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
	return USER_INFO_SECTION_MAX;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch (section) 
	{
		case USER_DETAIL:
			return USER_DETAIL_MAX;
		default:
			return 1;
	}
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell;
	
	switch (indexPath.section) 
	{
	case USER_DETAIL:
		{
			NSString *cellType = USER_DETAIL_TITLE[indexPath.row];
			cell = [tableView dequeueReusableCellWithIdentifier:cellType];
			
			if (nil == cell)
			{
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 
							       reuseIdentifier:cellType] autorelease];
				cell.textLabel.textColor = [Color grey2];
				cell.textLabel.font = [UIFont systemFontOfSize:13.0];
				cell.textLabel.text = USER_DETAIL_TITLE[indexPath.row];
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				
				CGFloat X = 75.0;
				CGFloat Y = 0.0;
				CGFloat width = (cell.contentView.frame.size.width) - (X + 28.0);
				CGFloat height = DEFAULT_CELL_HEIGHT;
				CGRect frame = CGRectMake(X, Y, width, height);
				_userDetailTextView[indexPath.row].frame = frame;
				_userDetailTextView[indexPath.row].center = CGPointMake(_userDetailTextView[indexPath.row].center.x, 
											cell.center.y);
				
				[cell.contentView addSubview:_userDetailTextView[indexPath.row]];
			}
		}
			break;
		case USER_AVATOR:
		{
			cell = self.avatorCell;
		}
			break;
		case USER_INTRO:
		{
			NSString *CellIdentifier = @"UserIntro";
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			
			if (nil == cell) 
			{
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
							       reuseIdentifier:CellIdentifier] autorelease];
				
				CGRect frame = CGRectMake(0.0, 
							  0.0, 
							  cell.contentView.frame.size.width, 
							  88 * PROPORTION());
				
				self.introduceView.frame = frame;
				
				[cell.contentView addSubview:self.introduceView];
			}
		}
			break;
	default:
		cell = nil;
	}
	
	if (self.editable)
	{
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	else
	{
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
	return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  
{ 
	switch (indexPath.section)
	{
	case USER_INTRO:
		{
			NSString *descString = self.introduceView.text;
			CGRect frame = self.introduceView.frame;
			frame.size.width = self.introduceView.superview.frame.size.width;
			frame.size.height = self.introduceView.superview.frame.size.height;
			self.introduceView.frame = frame;
			self.introduceView.text = descString;
			
			frame = self.introduceView.frame;
			frame.size.height = MAX(self.introduceView.contentSize.height, 88 * PROPORTION());
			self.introduceView.frame = frame;
			self.introduceView.text = descString;
			
			return frame.size.height;
		}
			break;
			
	case USER_AVATOR:
			return AVATOR_CELL_HEIGTH * PROPORTION();
			
			break;
		
	default:
			return DEFAULT_CELL_HEIGHT;

	}
	
	

}

#pragma mark - Table view delegate

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
	switch (section)
	{
	case USER_INTRO:
		return USER_INTRO_TITLE;
		break;
	default:
		return nil;
	}
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == USER_AVATOR)
	{
		self.photoSelector.delegate = self;
		[self.photoSelector.actionSheet showFromTabBar:self.navigationController.tabBarController.tabBar];
		[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
}

// did not provide selectable cell
-(NSIndexPath *) tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ((indexPath.section == USER_AVATOR) && (self.editable))
	{
		return indexPath;
	}
	else
	{
		return nil;
	}
}

#pragma mark - user info

- (void) getUserProfile
{
	
	NSDictionary *userProfile = [ProfileMananger getObjectWithNumberID:GET_USER_ID()];
	
	if (nil != userProfile)
	{		
		NSString *introduceString = [userProfile valueForKey:@"intro"];
		
		_userDetailTextView[USER_NAME].text = [userProfile valueForKey:@"nick"];
		_userDetailTextView[USER_PLACE].text = [userProfile valueForKey:@"city"];
		_introduceView.text = introduceString;
		
		self.avatorCell.avatorImageV.picID = [userProfile valueForKey:@"avatar"];
		
		[self.tableView reloadData];
	}
	else
	{
		[ProfileMananger requestObjectWithNumberID:GET_USER_ID() andHandler:@selector(getUserProfile) andTarget:self];
	}
}

- (void) sendUserInfoRequest
{	
	NSNumber *loginUserID = [GET_USER_ID() retain];
	
	if (nil == loginUserID)
	{
		[LoginManager requestWithHandler:@selector(sendUserInfoRequest) andTarget:self];
		
		return;
	}
	
	[self getUserProfile];
	
	[loginUserID release];
}

- (void) forceUpdateUserInfo
{
	NSNumber *loginUserID = [GET_USER_ID() retain];
	
	if (nil == loginUserID)
	{
		[LoginManager requestWithHandler:@selector(forceUpdateUserInfo) andTarget:self];
	}
	else
	{
		[ProfileMananger requestObjectWithNumberID:GET_USER_ID() andHandler:@selector(getUserProfile) andTarget:self]; 
	}
}

#pragma mark - action and interface 

- (BOOL) checkParamsNotEmpty
{
	BOOL paramsReady = YES;
	
	for (int i = 0; i < USER_DETAIL_MAX; ++i)
	{
		if (0 >= _userDetailTextView[i].text.length)
		{
			paramsReady = NO;
		}
	}
	
	if (nil == self.avatorCell.avatorImageV.picID)
	{
		paramsReady = NO;
	}
	
	return paramsReady;
}

- (BOOL) checkParamsChanged
{
	BOOL paramsChanged = NO;		
	NSDictionary *orginUserInfo = [ProfileMananger getObjectWithNumberID:GET_USER_ID()];

	if (![_userDetailTextView[USER_NAME].text isEqualToString:[orginUserInfo valueForKey:@"nick"]])
	{
		paramsChanged = YES;
	}
	
	if (![_userDetailTextView[USER_PLACE].text isEqualToString:[orginUserInfo valueForKey:@"city"]])
	{
		paramsChanged = YES;
	}
	
	if (!CHECK_EQUAL(self.avatorCell.avatorImageV.picID ,[orginUserInfo valueForKey:@"avatar"]))
	{
		paramsChanged = YES;
	}

	
	if (![self.introduceView.text isEqualToString:[orginUserInfo valueForKey:@"intro"]])
	{
		paramsChanged = YES;
	}
	
	return paramsChanged;
}

- (void) updateSaveButton
{
	if ([self checkParamsNotEmpty] && [self checkParamsChanged])
	{
		self.saveButton.enabled = YES;
	}
	else
	{
		self.saveButton.enabled = NO;
	}
}

- (void) startEditUserInfo:(id)sender
{
	self.editable = YES;
	self.introduceView.editable = YES;
	self.introduceView.userInteractionEnabled = YES;
	
	if (nil == self.cancelButton)
	{
		UIBarButtonItem *cancelButton = SETUP_BAR_TEXT_BUTTON(@"取消", self, @selector(cancelEdit:));
		self.cancelButton = cancelButton;
	}
	
	if (nil == self.saveButton)
	{
		UIBarButtonItem *saveButton = SETUP_BAR_TEXT_BUTTON(@"保存", self, @selector(saveUserInfo:));
		self.saveButton = saveButton;
	}
	
	self.navigationItem.leftBarButtonItem = self.cancelButton;
	self.navigationItem.rightBarButtonItem = self.saveButton;

	[self.tableView reloadData];
	
	[self updateSaveButton];
}

- (void) cancelEdit:(id)sender
{
	self.editable = NO;
	self.introduceView.editable = NO;
	self.introduceView.userInteractionEnabled = NO;
	
	self.navigationItem.rightBarButtonItem = self.editButton;
	self.navigationItem.leftBarButtonItem = self.backButton;
	self.avatorCell.accessoryType = UITableViewCellAccessoryNone;
	[self.avatorCell hideProgressBar];
	
	[self sendUserInfoRequest];
}

- (void) handlerForUpdate:(id)result
{
	[self getUserProfile];
}

- (void) sendUserInfo
{
	if ([self checkParamsNotEmpty] && [self checkParamsChanged])
	{
		NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
		
		NSDictionary *orginUserInfo = [ProfileMananger getObjectWithNumberID:GET_USER_ID()];
		
		if (!CHECK_EQUAL(_userDetailTextView[USER_NAME].text, 
				 [orginUserInfo valueForKey:@"nick"]))
		{
			[params setValue:_userDetailTextView[USER_NAME].text forKey:@"nick"];
		}
		
		if (!CHECK_EQUAL(_userDetailTextView[USER_PLACE].text,
		     [orginUserInfo valueForKey:@"city"]))
		{
			[params setValue:_userDetailTextView[USER_PLACE].text forKey:@"city"];
		}
		
		if (!CHECK_EQUAL(self.avatorCell.avatorImageV.picID ,[orginUserInfo valueForKey:@"avatar"]))
		{
			[params setValue:self.avatorCell.avatorImageV.picID forKey:@"avatar"];
		}
		
		
		if (!CHECK_EQUAL(self.introduceView.text, [orginUserInfo valueForKey:@"intro"]))
		{
			[params setValue:self.introduceView.text forKey:@"intro"];
		}
		
		if (0 < params.count) 
		{
			[params setValue:GET_USER_ID() forKey:@"id"];
			
			[ProfileMananger updateProfile:params withHandler:@selector(handlerForUpdate:) andTarget:self];
		}
		
		[params release];
	}
}

- (void) saveUserInfo:(id)sender
{
	self.editable = NO;
	self.introduceView.editable = NO;
	
	[self sendUserInfo];

	self.navigationItem.rightBarButtonItem = self.editButton;
	self.navigationItem.leftBarButtonItem = self.backButton;
}

#pragma mark - PhototSelectorDelegate

- (void) uploadImageHandler:(id)result
{
	// TODO handle error result
	
	[self.avatorCell hideProgressBar];
	self.avatorCell.avatorImageV.picID = [[result valueForKey:@"result"] valueForKey:@"id"];
	
	[self updateSaveButton];
}

- (void) dismissSelector:(PhotoSelector *)selector
{
	[self dismissModalViewControllerAnimated:YES];
}

- (void) showModalView:(UIViewController *)modalView
{
	[self presentModalViewController:modalView animated:YES];
}

- (void) didSelectPhotoWithSelector:(PhotoSelector *)selector
{
	self.avatorCell.avatorImageV.picID = nil;
	[self.avatorCell showProgressBar];

	NSInteger uploadID = [ImageManager createImage:selector.selectedImage 
					  withHandler:@selector(uploadImageHandler:) 
					    andTarget:self];
	NSString *uploadIDString = [[NSString alloc] initWithFormat:@"%u", uploadID];
	
	BIND_PROGRESS_VIEW_WITH_FILE_ID(self.avatorCell.progressBar, uploadIDString);

	[self updateSaveButton];
	
	// release the origin image
	selector.selectedImage = nil;
	
	[uploadIDString release];
}

#pragma mark TextInputerDelegate

- (void) showTextInputer
{
	if (nil == self.textInputer)
	{
		TextInputer *textInputer = [[TextInputer alloc] init];
		textInputer.delegate = self;
		textInputer.sendButtonTitle = @"完成";
		textInputer.drawCancel = NO;
		textInputer.title = @"个人介绍";
		textInputer.acceptEmpty = YES;
		
		self.textInputer = textInputer;
		
		[textInputer release];
	}
	
	self.textInputer.text.text = self.introduceView.text;
	
	[self.navigationController pushViewController:self.textInputer animated:YES];
}

- (void) hideInputer
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (void) textDoneWithTextInputer:(TextInputer *)inputer
{
	self.introduceView.text = inputer.text.text;
	
	[self.tableView reloadData];
	[self.introduceView resignFirstResponder];
	
	[self updateSaveButton];

	[self hideInputer];
}

- (void) cancelWithTextInputer:(TextInputer *)inputer
{
	[self hideInputer];
}

#pragma mark - UITextFieldDelegate

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
	return  self.editable;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
	if ([textField isFirstResponder])
	{
		[textField resignFirstResponder];
	}
	
	[self updateSaveButton];
	
	return YES;
}

#pragma mark - UITextViewDelegate

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
	if (self.introduceView == textView)
	{
		[self showTextInputer];
	}
	
	[textView resignFirstResponder];
	
	return NO;
}

- (BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
	NSUInteger newLength = [textView.text length] + [text length] - range.length;
	
	return (newLength > MAX_TEXT_LENGTH) ? NO : YES;
}

#pragma mark - class interface

+ (void) reloadData
{
	[[self getInstnace] forceUpdateUserInfo];
}

@end

