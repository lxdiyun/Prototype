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
#import "ProfileMananger.h"
#import "LoginManager.h"
#import "TagSelector.h"
#import "EventPage.h"

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

static UITextField *gs_food_detail_text_view[NEW_FOOD_DETAIL_MAX] = {nil};
static UITextView *gs_food_desc_text_view = nil;
static UILabel *gs_food_detail_star_label[NEW_FOOD_DETAIL_MAX] = {nil};
static UILabel *gs_food_desc_star_label = nil;
static CreateFoodImage *gs_create_food_image_header;
static CreateFoodFourCount *gs_create_food_fout_count_header;
static TextInputer *gs_food_desc_inputer =  nil;
static TagSelector *gs_tag_selector = nil;
static BOOL gs_need_scroll_to_begin = NO;

@interface CreateFoodPage () <UITextFieldDelegate, UITextViewDelegate, TextInputerDeletgate, CreateFoodFourCountDelegate, TagSelectorDelegate>
- (void) updateCity;
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

- (void) viewDidLoad
{
	[super viewDidLoad];

	for (int i = 0; i < NEW_FOOD_DETAIL_MAX; ++i)
	{
		gs_food_detail_text_view[i] = nil;
		gs_food_detail_star_label[i] = nil;
	}

	gs_food_desc_text_view = nil;
	gs_create_food_image_header = nil;
	gs_food_desc_inputer = nil;
	gs_create_food_fout_count_header = nil;
	gs_food_desc_star_label = nil;
	gs_tag_selector = nil;

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

- (void) viewDidUnload
{
	[super viewDidUnload];

	for (int i = 0; i < NEW_FOOD_DETAIL_MAX; ++i)
	{
		[gs_food_detail_text_view[i] release];
		gs_food_detail_text_view[i] = nil;
		[gs_food_detail_star_label[i] release];
		gs_food_detail_star_label[i] = nil;
	}

	[gs_food_desc_text_view release]; 
	gs_food_desc_text_view = nil;

	[gs_create_food_image_header release];
	gs_create_food_image_header = nil;

	[gs_food_desc_inputer release];
	gs_food_desc_inputer = nil;

	[gs_create_food_fout_count_header release];
	gs_create_food_fout_count_header = nil;

	[gs_food_desc_star_label release];
	gs_food_desc_star_label = nil;

	[gs_tag_selector release];
	gs_tag_selector = nil;
}

- (void) viewWillAppear:(BOOL)animated
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

- (void) viewDidAppear:(BOOL)animated
{
	if (gs_need_scroll_to_begin)
	{
		[self scrollToBegin];
	}

	[self updateCity];
	[super viewDidAppear:animated];
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

- (UILabel *) createStarLabel
{

	UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(5.0, 0.0, FONT_SIZE * PROPORTION(), FONT_SIZE * PROPORTION())] autorelease];
	label.text = @"*";
	label.backgroundColor = [UIColor clearColor];
	label.textColor = [UIColor redColor];
	label.font = [UIFont boldSystemFontOfSize:FONT_SIZE * PROPORTION()];

	return label;
}

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

				if (nil == gs_food_detail_text_view[indexPath.row])
				{
					CGFloat X = 75.0;
					CGFloat Y = 0.0;
					CGFloat width = (cell.contentView.frame.size.width - X - 28.0) * PROPORTION();
					CGFloat height = 44 * PROPORTION();
					gs_food_detail_text_view[indexPath.row] = [[UITextField alloc] initWithFrame:CGRectMake(X, 
																Y, 
																width, 
																height)];
					gs_food_detail_text_view[indexPath.row].center = CGPointMake(gs_food_detail_text_view[indexPath.row].center.x, cell.center.y);
					gs_food_detail_text_view[indexPath.row].font = [UIFont boldSystemFontOfSize:FONT_SIZE * PROPORTION()];
					gs_food_detail_text_view[indexPath.row].delegate = self;
					gs_food_detail_text_view[indexPath.row].contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
					gs_food_detail_text_view[indexPath.row].returnKeyType = UIReturnKeyNext;

					if (FOOD_TAG != indexPath.row)
					{
						if (nil == gs_food_detail_star_label[indexPath.row])
						{
							gs_food_detail_star_label[indexPath.row] = [[self createStarLabel] retain];
						}

						[cell.contentView addSubview:gs_food_detail_star_label[indexPath.row]];
					}
				}

				[cell.contentView addSubview:gs_food_detail_text_view[indexPath.row]];
			}

			if (FOOD_CITY == indexPath.row)
			{
				[self updateCity];
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

				if (nil == gs_food_desc_text_view)
				{
					gs_food_desc_text_view = [[UITextView alloc] initWithFrame:CGRectMake(0.0, 
													      0.0, 
													      cell.contentView.frame.size.width, 
													      88 * PROPORTION())];
					gs_food_desc_text_view.scrollEnabled = NO;
					gs_food_desc_text_view.backgroundColor = [UIColor clearColor];
					gs_food_desc_text_view.font = [UIFont boldSystemFontOfSize:FONT_SIZE * PROPORTION()];
					gs_food_desc_text_view.delegate = self;
				}

				[cell.contentView addSubview:gs_food_desc_text_view];

				if (nil == gs_food_desc_star_label)
				{
					gs_food_desc_star_label = [[self createStarLabel] retain];
				}

				[cell.contentView addSubview:gs_food_desc_star_label];
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
			if (nil == gs_create_food_image_header)
			{
				gs_create_food_image_header = [[CreateFoodImage alloc] 
					initWithFrame:CGRectMake(0.0, 
								 0.0, 
								 self.view.frame.size.width, 
								 self.view.frame.size.width)];
				[gs_create_food_image_header redrawAll];
			}

			return gs_create_food_image_header;
		}
		break;
	case FOOD_FOUR_COUNT:
		{
			if (nil == gs_create_food_fout_count_header)
			{
				gs_create_food_fout_count_header = [[CreateFoodFourCount alloc] 
					initWithFrame:CGRectMake(0.0, 
								 0.0, 
								 self.view.frame.size.width, 
								 44 * PROPORTION())];
				gs_create_food_fout_count_header.delegate = self;
			}

			return gs_create_food_fout_count_header;
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
		{
			// configure the description cell
			NSString *descString = gs_food_desc_text_view.text;
			CGRect frame = gs_food_desc_text_view.frame;
			frame.size.width = gs_food_desc_text_view.superview.frame.size.width;
			frame.size.height = gs_food_desc_text_view.superview.frame.size.height;
			gs_food_desc_text_view.frame = frame;
			gs_food_desc_text_view.text = descString;

			frame = gs_food_desc_text_view.frame;
			frame.size.height = MAX(gs_food_desc_text_view.contentSize.height, 88 * PROPORTION());
			gs_food_desc_text_view.frame = frame;
			gs_food_desc_text_view.text = descString;

			return frame.size.height;
		}
		break;

	default:
		return 44 * PROPORTION();
		break;
	}
}

#pragma mark - interface and action

- (void) requestUserCity
{
	NSNumber *loginID = GET_USER_ID();

	if (nil != loginID)
	{
		NSDictionary *loginUserProfile = [ProfileMananger getObjectWithNumberID:loginID];

		if (nil != loginUserProfile)
		{
			gs_food_detail_text_view[FOOD_CITY].text = [loginUserProfile valueForKey:@"city"];
			[self checkParamsReady];
		}
		else
		{
			[ProfileMananger requestObjectWithNumberID:loginID andHandler:@selector(requestUserCity) andTarget:self];
		}
	}
	else
	{
		[LoginManager requestWithHandler:@selector(requestUserCity) andTarget:self];
	}

}

- (void) updateCity
{
	if (nil != gs_food_detail_text_view[FOOD_CITY])
	{
		if (0 == gs_food_detail_text_view[FOOD_CITY].text.length)
		{
			[self requestUserCity];
		}
	}
}

- (void) resetImageWithUploadFileID:(NSInteger)fileID;
{
	if (nil != gs_create_food_image_header)
	{
		NSString *IDString = [[NSString alloc] initWithFormat:@"%u", fileID];

		gs_create_food_image_header.uploadFileID = IDString;
		[gs_create_food_image_header resetProgress];

		[IDString release];
	}
}

- (void) needScrollToBegin
{
	gs_need_scroll_to_begin = YES;
}

- (void) scrollToBegin
{
	gs_need_scroll_to_begin = NO;

	[gs_food_detail_text_view[FOOD_NAME] becomeFirstResponder];
}

- (BOOL) checkParamsReady
{
	BOOL paramsReady = YES;

	if (nil == gs_create_food_image_header.selectedImage.picID)
	{
		paramsReady = NO;
	}

	for (int i = 0; i < NEW_FOOD_DETAIL_MAX; ++i)
	{
		if (FOOD_TAG == i)
		{
			continue;
		}

		if (0 >= gs_food_detail_text_view[i].text.length)
		{
			paramsReady = NO;
			gs_food_detail_star_label[i].textColor = [UIColor redColor];
		}
		else
		{
			gs_food_detail_star_label[i].textColor = [UIColor clearColor];
		}
	}

	if (0 >= gs_food_desc_text_view.text.length)
	{
		paramsReady = NO;
		gs_food_desc_star_label.textColor = [UIColor redColor];
	}
	else
	{
		gs_food_desc_star_label.textColor = [UIColor clearColor];
	}

	if (![gs_create_food_fout_count_header isFourCountSelected])
	{
		paramsReady = NO;
	}

	return paramsReady;
}

- (void) updateShareButton
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

- (void) imageUploadCompleted:(id)result
{
	NSNumber *picID = [[result valueForKey:@"result"] valueForKey:@"id"];

	if (CHECK_NUMBER(picID))
	{
		gs_create_food_image_header.selectedImage.picID = picID;
	}

	[self updateShareButton];
}

- (void) createFood:(id)sender
{
	if ([self checkParamsReady])
	{
		NSMutableDictionary *params = [[NSMutableDictionary alloc] init];

		[params setValue:gs_food_detail_text_view[FOOD_NAME].text forKey:@"name"];
		[params setValue:gs_food_detail_text_view[FOOD_CITY].text forKey:@"city"];
		[params setValue:gs_food_detail_text_view[FOOD_PLACE].text forKey:@"place_name"];
		[params setValue:gs_food_desc_text_view.text forKey:@"desc"];
		[params setValue:gs_create_food_image_header.selectedImage.picID forKey:@"pic"];
		[params setValue:[gs_food_detail_text_view[FOOD_TAG].text componentsSeparatedByString:@" "] forKey:@"category"];
		[gs_create_food_fout_count_header setFoutCountParams:params];

		[FoodManager createFood:params withHandler:@selector(foodCreated:) andTarget:self];
		
		self.navigationItem.rightBarButtonItem.enabled = NO;

		[params release];
	}
	
	[self dismissModalViewControllerAnimated:YES];
}

- (void) cancelCreate:(id)sender
{
	[gs_create_food_image_header cleanImage];

	[self dismissModalViewControllerAnimated:YES];
}

- (void) foodCreated:(id)result
{
	@autoreleasepool 
	{
		[gs_create_food_fout_count_header cleanFourCount];

		gs_create_food_image_header.selectedImage.picID = nil;

		for (int i = 0; i < NEW_FOOD_DETAIL_MAX; ++i)
		{
			if (FOOD_CITY == i)
			{
				// Do not clean city text
				continue;
			}

			gs_food_detail_text_view[i].text = @"";
		}

		gs_food_desc_text_view.text = @"";

		[gs_create_food_image_header cleanImage];
		
		[self updateShareButton];

		[EventPage requestUpdate];
	}

}

- (void) showTextInputer
{
	if (nil == gs_food_desc_inputer)
	{
		gs_food_desc_inputer = [[TextInputer alloc] init];
		gs_food_desc_inputer.delegate = self;
		gs_food_desc_inputer.sendButtonTitle = @"完成";
		gs_food_desc_inputer.drawCancel = NO;
		gs_food_desc_inputer.title = @"美食介绍";
		[gs_food_desc_inputer redraw];
	}

	gs_food_desc_inputer.text.text = gs_food_desc_text_view.text;


	[self.navigationController pushViewController:gs_food_desc_inputer animated:YES];
}

#pragma mark - UITextFieldDelegate

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{	
	[self updateShareButton];

	int i;

	for ( i = 0; i < NEW_FOOD_DETAIL_MAX - 1; ++i)
	{
		if ([gs_food_detail_text_view[i] isFirstResponder])
		{
			[textField resignFirstResponder];
			[gs_food_detail_text_view[i + 1] becomeFirstResponder];

			break;
		}
	}


	if (i == (NEW_FOOD_DETAIL_MAX - 1))
	{
		[textField resignFirstResponder];
		[gs_food_desc_text_view becomeFirstResponder];

		return NO;
	}

	return YES;
}

- (void) textFieldDidBeginEditing:(UITextField *)textField
{
	for (int i = 0; i < NEW_FOOD_DETAIL_MAX; ++i)
	{
		if (gs_food_detail_text_view[i] == textField)
		{
			break;
		}
	}
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
	[self updateShareButton];
}

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
	if (gs_food_detail_text_view[FOOD_TAG] == textField)
	{
		if (0 >= textField.text.length)
		{
			if (nil == gs_tag_selector)
			{
				gs_tag_selector = [[TagSelector alloc] init];
				gs_tag_selector.delegate = self;
			}

			if (self.navigationController.topViewController != gs_tag_selector)
			{
				[self.navigationController pushViewController:gs_tag_selector animated:YES];

				return NO;
			}
		}
	}

	return YES;
}

#pragma mark - UITextViewDelegate

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
	if (gs_food_desc_text_view == textView)
	{
		[self showTextInputer];
	}

	return NO;
}

#pragma mark - TextInputerDeletgate

- (void) textDoneWithTextInputer:(TextInputer *)inputer
{
	gs_food_desc_text_view.text = inputer.text.text;
	inputer.text.text = nil;
	[self.navigationController popViewControllerAnimated:YES];
	[self.tableView reloadData];
	[gs_food_desc_text_view resignFirstResponder];
	
	[self updateShareButton];
}

- (void) cancelWithTextInputer:(TextInputer *)inputer
{
	[self.navigationController popViewControllerAnimated:YES];
	inputer.text.text = nil;
	[gs_food_desc_text_view resignFirstResponder];
}

#pragma mark - CreateFoodFourCountDelegate

- (void) fourCountSelected
{
	[self updateShareButton];
}

#pragma mark - TagSelectorDelegate

- (void) focusFoodText
{	
	if (![gs_food_detail_text_view[FOOD_TAG] isFirstResponder])
	{
		[gs_food_detail_text_view[FOOD_TAG] becomeFirstResponder];
	}

	[self.navigationController popViewControllerAnimated:YES];
}

- (void) didSelectTags:(TagSelector *)sender
{
	gs_food_detail_text_view[FOOD_TAG].text = sender.selctedTags;
	sender.selctedTags = nil;

	[self focusFoodText];
}

- (void) cancelSelectTags:(TagSelector *)sender
{
	[self focusFoodText];
}

@end
