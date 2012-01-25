//
//  NewFoodView.m
//  Prototype
//
//  Created by Adrian Lee on 1/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CreateFoodPage.h"

#import "TextFieldCell.h"
#import "CreateFoodImage.h"
#import "Util.h"
#import "FoodManager.h"
#import "TextInputer.h"
#import "CreateFoodFourCount.h"

const static CGFloat FONT_SIZE = 15.0;

typedef enum NEW_FOOD_SECTION_ENUM
{
	FOOD_IMAGE = 0x0,
	FOOD_FOUR_COUNT = 0x1,
	FOOD_DETAIL = 0x2,
	FOOD_DESC = 0x3,
	NEW_FOOD_SECTION_MAX
} NEW_FOOD_SECTION;

typedef enum NEW_FOOD_DETAIL_ENUM
{
	FOOD_NAME = 0x0,
	FOOD_CITY = 0x1,
	FOOD_PLACE = 0x2,
	FOOD_TAG = 0x3,
	NEW_FOOD_DETAIL_MAX
} NEW_FOOD_DETAIL;

static NSString *FOOD_DETAIL_TITLE[NEW_FOOD_DETAIL_MAX] = {@"名字：", @"城市：", @"所在地：", @"类型："};
static UITextField *FOOD_DETAIL_TETX_VIEW[NEW_FOOD_DETAIL_MAX] = {nil};
static UITextView *FOOD_DESC_TEXT_VIEW = nil;
static CreateFoodImage *CREATE_FOOD_HEADER;
static CreateFoodFourCount *CREATE_FOOD_FOUR_COUNT_HEADER;
static TextInputer *FOOD_DESC_INPUTER =  nil;
static BOOL NEED_SCROOL_TO_BEGIN = NO;

@interface CreateFoodPage () <UITextFieldDelegate, UITextViewDelegate, TextInputerDeletgate, CreateFoodFourCountDelegate>
- (BOOL) checkParamsReady;
- (void) scrollToBegin;
@end

@implementation CreateFoodPage

- (id)initWithStyle:(UITableViewStyle)style
{
	self = [super initWithStyle:UITableViewStyleGrouped];
	if (self) 
	{
		self.view.backgroundColor = [Color milkColor];
	}
	return self;
}

- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];

	// Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];

	for (int i = 0; i < NEW_FOOD_DETAIL_MAX; ++i)
	{
		FOOD_DETAIL_TETX_VIEW[i] = nil;
	}

	FOOD_DESC_TEXT_VIEW = nil;
	CREATE_FOOD_HEADER = nil;
	FOOD_DESC_INPUTER = nil;
	CREATE_FOOD_FOUR_COUNT_HEADER = nil;

	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"分享" 
										  style:UIBarButtonItemStyleDone 
										 target:self 
										 action:@selector(createFood:)];
	
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" 
										 style:UIBarButtonItemStylePlain 
										target:self 
										action:@selector(cancelCreate:) ]; 
	self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)viewDidUnload
{
	[super viewDidUnload];

	for (int i = 0; i < NEW_FOOD_DETAIL_MAX; ++i)
	{
		[FOOD_DETAIL_TETX_VIEW[i] release];
		FOOD_DETAIL_TETX_VIEW[i] = nil;
	}

	[FOOD_DESC_TEXT_VIEW release]; 
	FOOD_DESC_TEXT_VIEW = nil;

	[CREATE_FOOD_HEADER release];
	CREATE_FOOD_HEADER = nil;

	[FOOD_DESC_INPUTER release];
	FOOD_DESC_INPUTER = nil;
	
	[CREATE_FOOD_FOUR_COUNT_HEADER release];
	CREATE_FOOD_FOUR_COUNT_HEADER = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	if ([self checkParamsReady])
	{
		self.navigationItem.rightBarButtonItem.enabled = YES;
	}
	else
	{
		self.navigationItem.rightBarButtonItem.enabled = NO;
	}
}

- (void)viewDidAppear:(BOOL)animated
{
	if (NEED_SCROOL_TO_BEGIN)
	{
		[self scrollToBegin];
	}

	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
	return NEW_FOOD_SECTION_MAX;
}


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	// Return the number of rows in the section.

	switch (section)
	{
	case FOOD_DETAIL:
		return NEW_FOOD_DETAIL_MAX;
		break;
	case FOOD_DESC:
		return 1;
		break;
	default:
		return 0;
		break;
	}
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (FOOD_DESC == section)
	{
		return @"美食介绍";
	}

	return nil;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch (indexPath.section) 
	{
	case FOOD_DETAIL:
		{

			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:FOOD_DETAIL_TITLE[indexPath.row]];

			if (cell == nil) 
			{
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2
							       reuseIdentifier:FOOD_DETAIL_TITLE[indexPath.row]] 
							       autorelease];
				cell.textLabel.textColor = [Color grey2Color];
				cell.textLabel.font = [UIFont systemFontOfSize:13.0 * PROPORTION()];
				cell.textLabel.text = FOOD_DETAIL_TITLE[indexPath.row];
				cell.selectionStyle = UITableViewCellSelectionStyleNone;

				if (nil == FOOD_DETAIL_TETX_VIEW[indexPath.row])
				{
					CGFloat X = 85.0;
					CGFloat Y = 0.0;
					CGFloat width = (self.view.frame.size.width - X - 12.0) * PROPORTION();
					CGFloat height = 44 * PROPORTION();
					FOOD_DETAIL_TETX_VIEW[indexPath.row] = [[UITextField alloc] initWithFrame:CGRectMake(X, 
															     Y, 
															     width, 
															     height)];
					FOOD_DETAIL_TETX_VIEW[indexPath.row].center = CGPointMake(FOOD_DETAIL_TETX_VIEW[indexPath.row].center.x, cell.center.y);
					FOOD_DETAIL_TETX_VIEW[indexPath.row].font = [UIFont boldSystemFontOfSize:FONT_SIZE * PROPORTION()];
					FOOD_DETAIL_TETX_VIEW[indexPath.row].delegate = self;
					FOOD_DETAIL_TETX_VIEW[indexPath.row].contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
					FOOD_DETAIL_TETX_VIEW[indexPath.row].returnKeyType = UIReturnKeyNext;
				}

				[cell addSubview:FOOD_DETAIL_TETX_VIEW[indexPath.row]];
			}

			return cell;

		}
		break;
	case FOOD_DESC:
		{
			static NSString *cellType = @"FoodDescription";

			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellType];

			if (cell == nil) 
			{
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
							       reuseIdentifier:cellType] autorelease];
				cell.selectionStyle = UITableViewCellSelectionStyleNone;

				if (nil == FOOD_DESC_TEXT_VIEW)
				{
					FOOD_DESC_TEXT_VIEW = [[UITextView alloc] initWithFrame:CGRectMake(10.0, 
													   0.0, 
													   self.view.frame.size.width - 20.0, 
													   88 * PROPORTION())];
					FOOD_DESC_TEXT_VIEW.backgroundColor = [UIColor clearColor];
					FOOD_DESC_TEXT_VIEW.font = [UIFont boldSystemFontOfSize:FONT_SIZE * PROPORTION()];
					FOOD_DESC_TEXT_VIEW.delegate = self;
				}

				[cell addSubview:FOOD_DESC_TEXT_VIEW];
			}

			return cell;
		}
		break;
	default:
		return nil;
		break;
	}
}

#pragma mark - UITableViewDelegate

- (NSIndexPath *) tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	return nil;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	switch (section) 
	{
		case FOOD_IMAGE:
		{
			if (nil == CREATE_FOOD_HEADER)
			{
				CREATE_FOOD_HEADER = [[CreateFoodImage alloc] 
						      initWithFrame:CGRectMake(0.0, 
									       0.0, 
									       self.view.frame.size.width, 
									       self.view.frame.size.width)];
				[CREATE_FOOD_HEADER redraw];
			}
			
			return CREATE_FOOD_HEADER;
		}
			break;
		case FOOD_FOUR_COUNT:
		{
			if (nil == CREATE_FOOD_FOUR_COUNT_HEADER)
			{
				CREATE_FOOD_FOUR_COUNT_HEADER = [[CreateFoodFourCount alloc] 
								 initWithFrame:CGRectMake(0.0, 
											  0.0, 
											  self.view.frame.size.width, 
											  44 * PROPORTION())];
				CREATE_FOOD_FOUR_COUNT_HEADER.delegate = self;
			}
			
			return CREATE_FOOD_FOUR_COUNT_HEADER;
		}
			
		default:
			return nil;
			break;
	}
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	switch (section) 
	{
		case FOOD_IMAGE:
			return self.view.frame.size.width;
			break;
		case FOOD_FOUR_COUNT:
			return 44.0 * PROPORTION();
			break;
		case FOOD_DESC:
			return 28.0 * PROPORTION();
			break;
		default:
			return 0;
			break;
	}
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch (indexPath.section) {
	case FOOD_DESC:
		return 88 * PROPORTION();
		break;

	default:
		return 44 * PROPORTION();
		break;
	}
}

#pragma mark - interface and action

- (void) resetImageWithUploadFileID:(uint32_t)fileID;
{
	if (nil != CREATE_FOOD_HEADER)
	{
		NSString *IDString = [[NSString alloc] initWithFormat:@"%u", fileID];
		
		CREATE_FOOD_HEADER.uploadFileID = IDString;
		[CREATE_FOOD_HEADER redraw];
		[CREATE_FOOD_HEADER resetProgress];
		
		[IDString release];
	}
}

- (void) needScrollToBegin
{
	NEED_SCROOL_TO_BEGIN = YES;
}

- (void) scrollToBegin
{
	NEED_SCROOL_TO_BEGIN = NO;
	
	[FOOD_DETAIL_TETX_VIEW[FOOD_NAME] becomeFirstResponder];
}

- (BOOL) checkParamsReady
{
	if (nil == CREATE_FOOD_HEADER.selectedImage.picID)
	{
		return NO;
	}

	for (int i = 0; i < NEW_FOOD_DETAIL_MAX; ++i)
	{
		if (0 >= FOOD_DETAIL_TETX_VIEW[i].text.length)
		{
			return NO;
		}
	}

	if (0 >= FOOD_DESC_TEXT_VIEW.text.length)
	{
		return NO;
	}

	return [CREATE_FOOD_FOUR_COUNT_HEADER isFourCountSelected];
}

- (void) imageUploadCompleted:(id)result
{
	NSNumber *picID = [[result valueForKey:@"result"] valueForKey:@"id"];

	if (CHECK_NUMBER(picID))
	{
		CREATE_FOOD_HEADER.selectedImage.picID = picID;
	}

	if ([self checkParamsReady])
	{
		self.navigationItem.rightBarButtonItem.enabled = YES;
	}
	else
	{
		self.navigationItem.rightBarButtonItem.enabled = NO;
	}
}

- (void) createFood:(id)sender
{
	if ([self checkParamsReady])
	{
		NSMutableDictionary *params = [[NSMutableDictionary alloc] init];

		[params setValue:FOOD_DETAIL_TETX_VIEW[FOOD_NAME].text forKey:@"name"];
		[params setValue:FOOD_DETAIL_TETX_VIEW[FOOD_CITY].text forKey:@"city"];
		[params setValue:FOOD_DETAIL_TETX_VIEW[FOOD_PLACE].text forKey:@"place_name"];
		[params setValue:FOOD_DESC_TEXT_VIEW.text forKey:@"desc"];
		[params setValue:CREATE_FOOD_HEADER.selectedImage.picID forKey:@"pic"];
		[params setValue:[FOOD_DETAIL_TETX_VIEW[FOOD_TAG].text componentsSeparatedByString:@" "] forKey:@"category"];
		[CREATE_FOOD_FOUR_COUNT_HEADER setFoutCountParams:params];

		[FoodManager createFood:params withHandler:@selector(foodCreated:) andTarget:self];

		[params release];
	}
}
- (void)cancelCreate:(id)sender
{
	[self dismissModalViewControllerAnimated:YES];
}

- (void) foodCreated:(id)result
{
	@autoreleasepool 
	{
		[CREATE_FOOD_FOUR_COUNT_HEADER cleanFourCount];
		
		CREATE_FOOD_HEADER.selectedImage.picID = nil;
		
		for (int i = 0; i < NEW_FOOD_DETAIL_MAX; ++i)
		{
			FOOD_DETAIL_TETX_VIEW[i].text = @"";
		}
		
		FOOD_DESC_TEXT_VIEW.text = @"";
		
		[self dismissModalViewControllerAnimated:YES];
	}
	
}

- (void) showTextInputer
{
	if (nil == FOOD_DESC_INPUTER)
	{
		FOOD_DESC_INPUTER = [[TextInputer alloc] init];
		FOOD_DESC_INPUTER.delegate = self;
		FOOD_DESC_INPUTER.sendButtonTitle = @"完成";
		FOOD_DESC_INPUTER.drawCancel = NO;
	}
	
	if (0 < FOOD_DESC_TEXT_VIEW.text.length)
	{
		FOOD_DESC_INPUTER.text.text = FOOD_DESC_TEXT_VIEW.text;
	}
	
	[self.navigationController pushViewController:FOOD_DESC_INPUTER animated:YES];
}

#pragma mark - UITextFieldDelegate

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{	
	if ([self checkParamsReady])
	{
		self.navigationItem.rightBarButtonItem.enabled = YES;
	}
	else
	{
		self.navigationItem.rightBarButtonItem.enabled = NO;
	}

	int i;

	for ( i = 0; i < NEW_FOOD_DETAIL_MAX - 1; ++i)
	{
		if ([FOOD_DETAIL_TETX_VIEW[i] isFirstResponder])
		{
			[textField resignFirstResponder];
			[FOOD_DETAIL_TETX_VIEW[i + 1] becomeFirstResponder];

			break;
		}
	}
	
	
	if (i == (NEW_FOOD_DETAIL_MAX - 1))
	{
		[textField resignFirstResponder];
		[FOOD_DESC_TEXT_VIEW becomeFirstResponder];
		
		return NO;
	}

	return YES;
}

- (void) textFieldDidBeginEditing:(UITextField *)textField
{
	for (int i = 0; i < NEW_FOOD_DETAIL_MAX; ++i)
	{
		if (FOOD_DETAIL_TETX_VIEW[i] == textField)
		{
			break;
		}
	}
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
	if ([self checkParamsReady])
	{
		self.navigationItem.rightBarButtonItem.enabled = YES;
	}
	else
	{
		self.navigationItem.rightBarButtonItem.enabled = NO;
	}
}

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
	return YES;
}

#pragma mark - UITextViewDelegate

- (void) textViewDidChange:(UITextView *)textView
{
	if ([self checkParamsReady])
	{
		self.navigationItem.rightBarButtonItem.enabled = YES;
	}
	else
	{
		self.navigationItem.rightBarButtonItem.enabled = NO;
	}
}

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
	if (FOOD_DESC_TEXT_VIEW == textView)
	{
		//[FOOD_DESC_TEXT_VIEW becomeFirstResponder];
		[self showTextInputer];
	}
	
	return NO;
}

#pragma mark - TextInputerDeletgate

- (void) textDoneWithTextInputer:(TextInputer *)inputer
{
	FOOD_DESC_TEXT_VIEW.text = inputer.text.text;
	[self.navigationController popViewControllerAnimated:YES];
	[FOOD_DESC_TEXT_VIEW resignFirstResponder];
}

- (void) cancelWithTextInputer:(TextInputer *)inputer
{
	[self.navigationController popViewControllerAnimated:YES];
	[FOOD_DESC_TEXT_VIEW resignFirstResponder];
}

#pragma mark - CreateFoodFourCountDelegate

- (void) fourCountSelected
{
	if ([self checkParamsReady])
	{
		self.navigationItem.rightBarButtonItem.enabled = YES;
	}
	else
	{
		self.navigationItem.rightBarButtonItem.enabled = NO;
	}
}

@end
