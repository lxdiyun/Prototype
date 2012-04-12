//
//  LoginPage.m
//  Prototype
//
//  Created by Adrian Lee on 1/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LoginPage.h"

#import <CommonCrypto/CommonDigest.h>

#import "Util.h"
#import "LoginManager.h"

const static CGFloat FONT_SIZE = 15.0;

typedef enum LOGIN_FILED_ENUM 
{
	ACCOUNT  = 0x0,
	PASSWORD = 0x1,
	LOGIN_FIELD_MAX
} LOGIN_FIELD;

static NSString *FIELD_TITLE[LOGIN_FIELD_MAX] = {@"邮箱：", @"密码："};

@interface LoginPage () <UITextFieldDelegate>
{
	UITextField *_loginFieldText[LOGIN_FIELD_MAX];
	UIBarButtonItem *_loginButton;
	NSString *_errorMessage;
}

@property (strong) UIBarButtonItem *loginButton;

- (void) updateLoginButton;
@end

@implementation LoginPage

@synthesize loginButton = _loginButton;
@synthesize errorMessage = _errorMessage;

#pragma mark - life circle

- (id) initWithStyle:(UITableViewStyle)style
{
	self = [super initWithStyle:UITableViewStyleGrouped];

	if (self) 
	{
		self.tableView.backgroundColor = [Color grey1Color];
		self.title = @"美食玩家";
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

- (void) viewDidLoad
{
	[super viewDidLoad];
	
	for (int i = 0; i < LOGIN_FIELD_MAX; ++i)
	{
		if (nil == _loginFieldText[i])
		{
			_loginFieldText[i] = [[UITextField alloc] init];
			_loginFieldText[i].font = [UIFont boldSystemFontOfSize:FONT_SIZE * PROPORTION()];
			_loginFieldText[i].delegate = self;
			_loginFieldText[i].contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
			if (ACCOUNT == i)
			{
				_loginFieldText[i].keyboardType = UIKeyboardTypeEmailAddress;
			}
			
			if (PASSWORD == i)
			{
				_loginFieldText[i].secureTextEntry = YES;
			}
			
			if (LOGIN_FIELD_MAX - 1 == i)
			{
				_loginFieldText[i].returnKeyType = UIReturnKeyDone;
			}
			else
			{
				_loginFieldText[i].returnKeyType = UIReturnKeyNext;
			}
		}
	}
	
	if (nil == self.loginButton)
	{
		UIBarButtonItem *loginButton = [[UIBarButtonItem alloc] initWithTitle:@"登陆" 
										style:UIBarButtonItemStyleDone 
									       target:self 
									       action:@selector(login:)];
		
		self.loginButton = loginButton;
		
		self.navigationItem.rightBarButtonItem = self.loginButton;
		
		[loginButton release];
	}
	
	self.errorMessage = nil;
}

- (void) viewDidUnload
{
	[super viewDidUnload];
	
	for (int i = 0; i < LOGIN_FIELD_MAX; ++i)
	{
		[_loginFieldText[i] release];
		
		_loginFieldText[i] = nil;
	}
	
	self.loginButton = nil;
}

- (void) viewWillAppear:(BOOL)animated
{
	[self  reloadData];

	[super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[self updateLoginButton];
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
	return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	// Return the number of rows in the section.
	return LOGIN_FIELD_MAX;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:FIELD_TITLE[indexPath.row]];
	if (cell == nil) 
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:FIELD_TITLE[indexPath.row]] autorelease];
		cell.textLabel.text = FIELD_TITLE[indexPath.row];
		cell.textLabel.textColor = [Color grey2Color];
		cell.textLabel.font = [UIFont systemFontOfSize:13.0];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		CGFloat X = 75.0;
		CGFloat Y = 0.0;
		CGFloat width = cell.contentView.frame.size.width - X;
		CGFloat height = 44;
		CGRect frame = CGRectMake(X, Y, width, height);
		_loginFieldText[indexPath.row].frame = frame;
		_loginFieldText[indexPath.row].center = CGPointMake(_loginFieldText[indexPath.row].center.x, 
								    cell.center.y);
		
		[cell.contentView addSubview:_loginFieldText[indexPath.row]];
	}
	
	return cell;
}

#pragma mark - Table view delegate

- (NSIndexPath *) tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	return nil;
}

- (NSString *) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	return self.errorMessage;
}

#pragma mark - action and interface

- (BOOL) checkParamsNotEmpty
{
	BOOL paramsReady = YES;
	
	for (int i = 0; i < LOGIN_FIELD_MAX; ++i)
	{
		if (0 >= _loginFieldText[i].text.length)
		{
			paramsReady = NO;
		}
	}
	
	return paramsReady;
}

- (void) updateLoginButton
{
	if ([self checkParamsNotEmpty] )
	{
		self.loginButton.enabled = YES;
	}
	else
	{
		self.loginButton.enabled = NO;
	}
}

- (void) login:(id)sender
{
	if ([self checkParamsNotEmpty])
	{
		@autoreleasepool 
		{
			NSString *account = _loginFieldText[ACCOUNT].text;
			NSString *password = _loginFieldText[PASSWORD].text;
			NSString *stringToHash = [NSString stringWithFormat:@"%@%@", [account lowercaseString], password];
			NSData *dataToHash = [stringToHash dataUsingEncoding:NSUTF8StringEncoding];
			NSMutableString *finalHashedPwd = [[NSMutableString alloc] init]; 
			unsigned char hashBytes[CC_SHA1_DIGEST_LENGTH];
			
			CC_SHA1([dataToHash bytes], [dataToHash length], hashBytes);
			
			for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; ++i)
			{
				[finalHashedPwd appendFormat:@"%02x", hashBytes[i]];
			}
			
			[[NSUserDefaults standardUserDefaults] setObject:account forKey:@"user_account"];
			[[NSUserDefaults standardUserDefaults] setObject:finalHashedPwd forKey:@"user_password"];
			[[NSUserDefaults standardUserDefaults] synchronize];

			[LoginManager changeLoginUser];
			
			[finalHashedPwd release];
		}
	}
}

- (void) reloadData
{
	[self.tableView reloadData];
	
	NSString *account = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_account"];
	
	[_loginFieldText[ACCOUNT] setText:account];
	[_loginFieldText[PASSWORD] setText:nil];
}


#pragma mark - UITextFieldDelegate

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{	
	[self updateLoginButton];

	for ( int i = 0; i < LOGIN_FIELD_MAX; ++i)
	{
		if ([_loginFieldText[i] isFirstResponder])
		{
			[textField resignFirstResponder];
			
			if (LOGIN_FIELD_MAX - 1 > i)
			{
				[_loginFieldText[i + 1] becomeFirstResponder];
			}
			
			break;
		}
	}
	
	return YES;
}


@end
