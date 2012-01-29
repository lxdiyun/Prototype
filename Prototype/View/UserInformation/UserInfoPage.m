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
#import "AvatorCell.h"
#import "LoginManager.h"
#import "ProfileMananger.h"
#import "PhotoSelector.h"
#import "ImageManager.h"

const static CGFloat FONT_SIZE = 15.0;

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

@interface  UserInfoPage   () <UITableViewDelegate, UITextFieldDelegate, PhototSelectorDelegate, UITextViewDelegate>
{
	NSNumber *_avatorID;
	PhotoSelector *_photoSelector;
	UITextView *_introduceView;
	UITextField *_userDetailTextView[USER_DETAIL_MAX];
}

@property (strong) UITextView *introduceView;
@property (assign) BOOL cellChanged;
@property (strong) NSNumber *avatorID;
@property (strong) PhotoSelector *photoSelector;

- (void) initViewDisplay;
- (void) sendUserInfoRequest;
@end

@implementation UserInfoPage

@synthesize introduceView = _introduceView;
@synthesize cellChanged = _cellChanged;
@synthesize avatorID = _avatorID;
@synthesize photoSelector = _photoSelector;

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

- (void) dealloc
{	
	[_introduceView release];
	[_avatorID release];
	
	[super dealloc];
}

#pragma mark - View lifecycle

- (void) viewDidLoad
{
	[super viewDidLoad];

	[self initViewDisplay];
	
	self.cellChanged = YES;
	
	for (int i = 0; i < USER_DETAIL_MAX; ++i)
	{
		_userDetailTextView[i] = nil;
	}

	// Uncomment the following line to preserve selection between presentations.
	// self.clearsSelectionOnViewWillAppear = NO;
	
	// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
	// self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void) initViewDisplay
{
	@autoreleasepool 
	{
		[self setTitle:@"个人设置"];
		self.photoSelector = [[[PhotoSelector alloc] init] autorelease];
		self.view.backgroundColor = [Color grey1Color];
	}
}

- (void) viewDidUnload
{

	self.introduceView = nil;
	self.avatorID = nil;
	self.photoSelector = nil;
	
	for (int i = 0; i < USER_DETAIL_MAX; ++i)
	{
		[_userDetailTextView[i] release];
		_userDetailTextView[i] = nil;
	}
	
	[super viewDidUnload];
}

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[self sendUserInfoRequest];
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
	switch (indexPath.section) 
	{
	case USER_DETAIL:
		{
			NSString *cellType = USER_DETAIL_TITLE[indexPath.row];
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellType];
			
			if (nil == cell)
			{
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 
							       reuseIdentifier:cellType] autorelease];
				cell.textLabel.textColor = [Color grey2Color];
				cell.textLabel.font = [UIFont systemFontOfSize:13.0 * PROPORTION()];
				cell.textLabel.text = USER_DETAIL_TITLE[indexPath.row];
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				
				if (nil == _userDetailTextView[indexPath.row])
				{
					CGFloat X = 75.0;
					CGFloat Y = 0.0;
					CGFloat width = (cell.contentView.frame.size.width - X) * PROPORTION();
					CGFloat height = 44 * PROPORTION();
					_userDetailTextView[indexPath.row] = [[UITextField alloc] initWithFrame:CGRectMake(X, 
																Y, 
																width, 
																height)];
					_userDetailTextView[indexPath.row].center = CGPointMake(_userDetailTextView[indexPath.row].center.x, cell.center.y);
					_userDetailTextView[indexPath.row].font = [UIFont boldSystemFontOfSize:FONT_SIZE * PROPORTION()];
					_userDetailTextView[indexPath.row].delegate = self;
					_userDetailTextView[indexPath.row].contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
					_userDetailTextView[indexPath.row].returnKeyType = UIReturnKeyNext;
				}
				
				[cell.contentView addSubview:_userDetailTextView[indexPath.row]];
			}

			return cell;
		}
			break;
		case USER_AVATOR:
		{
			AvatorCell *cell = [tableView dequeueReusableCellWithIdentifier:USER_AVATOR_TITLE];
			
			if (cell == nil) 
			{
				cell = [[[AvatorCell alloc] initWithStyle:UITableViewCellStyleValue2 
							  reuseIdentifier:USER_AVATOR_TITLE] autorelease];
				cell.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, 44 * PROPORTION());
				[cell redraw];
				cell.textLabel.textColor = [Color grey2Color];
				cell.textLabel.font = [UIFont systemFontOfSize:13.0 * PROPORTION()];
				cell.textLabel.text = USER_AVATOR_TITLE;
			}
			
			if (nil != self.avatorID)
			{
				cell.avatorImageV.picID = self.avatorID;
			}
			
			return cell;
		}
			break;
		case USER_INTRO:
		{
			NSString *CellIdentifier = @"UserIntro";
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			
			if (nil == cell) 
			{
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
							       reuseIdentifier:CellIdentifier] autorelease];
				
				if (nil == self.introduceView)
				{
					UITextView *textView = [[UITextView alloc] initWithFrame:CGRectZero];

					textView = [[UITextView alloc] initWithFrame:CGRectMake(0.0, 
												0.0, 
												cell.contentView.frame.size.width, 
												88 * PROPORTION())];
					textView.scrollEnabled = NO;
					textView.backgroundColor = [UIColor clearColor];
					textView.font = [UIFont boldSystemFontOfSize:FONT_SIZE * PROPORTION()];
					textView.delegate = self;
					
					self.introduceView = textView;
										
					[textView release];
				}
				
				[cell.contentView addSubview:self.introduceView];
			}
			
			
			
			return cell;
		}
			break;
	default:
		return nil;
	}
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
			break;
		}
		
	default:
				return 44 * PROPORTION();

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
		[self.photoSelector.actionSheet showInView:self.view];
		[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
}

// did not provide selectable cell
-(NSIndexPath *) tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == USER_AVATOR)
	{
		return indexPath;
	}
	else
	{
		return nil;
	}
}

#pragma mark - message

- (void) getUserProfile
{
	
	NSDictionary *userProfile = [ProfileMananger getObjectWithNumberID:GET_USER_ID()];
	
	if (nil != userProfile)
	{		
		NSString *introduceString = [userProfile valueForKey:@"intro"];
		
		_userDetailTextView[USER_NAME].text = [userProfile valueForKey:@"nick"];
		_userDetailTextView[USER_PLACE].text = [userProfile valueForKey:@"city"];
		_introduceView.text = introduceString;
		
		self.avatorID = [userProfile valueForKey:@"avatar"];
		
		self.cellChanged = YES;
		
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

#pragma mark - PhototSelectorDelegate

- (void) uploadImageHandler:(id)result
{
	self.avatorID = [[result valueForKey:@"result"] valueForKey:@"id"];
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
	[ImageManager createImage:selector.selectedImage 
		      withHandler:@selector(uploadImageHandler:) 
			andTarget:self];
	
	// release the origin image
	selector.selectedImage = nil;
}

#pragma mark - UITextFieldDelegate

@end

