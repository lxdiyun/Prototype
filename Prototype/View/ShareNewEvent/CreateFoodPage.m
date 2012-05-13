//
//  NewFoodView.m
//  Prototype
//
//  Created by Adrian Lee on 1/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CreateFoodPage.h"

#import "TextFieldCell.h"
#import "Util.h"
#import "FoodManager.h"
#import "TextInputer.h"
#import "ProfileMananger.h"
#import "LoginManager.h"
#import "TagSelector.h"
#import "EventPage.h"
#import "CreateFoodHeaderVC.h"

const static CGFloat  FONT_SIZE = 15.0;
const static CGFloat STAR_SIZE = 22;
static CGPoint TEXT_OFFSET = {0, 416};

typedef enum NEW_FOOD_SECTION_ENUM
{
	FOOD_HEADER = 0x0,
	FOOD_DETAIL = 0x1,
	FOOD_DESC = 0x2,
	NEW_FOOD_SECTION_MAX
} NEW_FOOD_SECTION;

typedef enum NEW_FOOD_DETAIL_ENUM
{
	FOOD_NAME = 0x0,
	FOOD_CITY = 0x1,
	FOOD_PLACE = 0x2,
	NEW_FOOD_DETAIL_MAX,
	// TODO revaluate to show tag
	FOOD_TAG = 0xFFFF
} NEW_FOOD_DETAIL;

static NSString *FOOD_DETAIL_TITLE[NEW_FOOD_DETAIL_MAX] = {@"名字：", @"城市：", @"餐馆："};

static UITextField *gs_food_detail_text_view[NEW_FOOD_DETAIL_MAX] = {nil};
static UITextView *gs_food_desc_text_view = nil;
static UILabel *gs_food_detail_star_label[NEW_FOOD_DETAIL_MAX] = {nil};
static TextInputer *gs_food_desc_inputer =  nil;
static TagSelector *gs_tag_selector = nil;

@interface CreateFoodPage () <UITextFieldDelegate, UITextViewDelegate, TextInputerDeletgate, TagSelectorDelegate>
{
	CreateFoodHeaderVC *_header;
	NSNumber *_uploadingID;
}
- (void) updateCity;
- (BOOL) checkParamsReady;

@property (retain, nonatomic) CreateFoodHeaderVC *header;
@property (retain, nonatomic) NSNumber *uploadingID;
@end

@implementation CreateFoodPage

@synthesize header = _header;
@synthesize uploadingID = _uploadingID;

- (id) initWithStyle:(UITableViewStyle)style
{
	self = [super initWithStyle:UITableViewStyleGrouped];
	if (self) 
	{
		@autoreleasepool 
		{
			self.view.backgroundColor = [Color lightyellowColor];
			self.header = [[[CreateFoodHeaderVC alloc] init] autorelease];
			self.title = @"分享美食";
		}
	}
	return self;
}

- (void) cleanData
{
	self.header = nil;
	self.uploadingID = nil;
	
	for (int i = 0; i < NEW_FOOD_DETAIL_MAX; ++i)
	{
		[gs_food_detail_text_view[i] release];
		gs_food_detail_text_view[i] = nil;
		[gs_food_detail_star_label[i] release];
		gs_food_detail_star_label[i] = nil;
	}
	
	[gs_food_desc_text_view release]; 
	gs_food_desc_text_view = nil;
	
	[gs_food_desc_inputer release];
	gs_food_desc_inputer = nil;
	
	[gs_tag_selector release];
	gs_tag_selector = nil;
}

- (void) didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];

	// Release any cached data, images, etc that aren't in use.
}

- (void) dealloc
{
	[self cleanData];
	
	[super dealloc];
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
	gs_tag_selector = nil;

	self.navigationItem.rightBarButtonItem = SETUP_BAR_TEXT_BUTTON(@"分享", self, @selector(createFood:));

	self.navigationItem.leftBarButtonItem = SETUP_BAR_TEXT_BUTTON(@"取消", self, @selector(cancelCreate:));
	self.navigationItem.rightBarButtonItem.enabled = NO;
	
}

- (void) viewDidUnload
{
	[self cleanData];
	[super viewDidUnload];
}

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	[self updateShareButton];
}

- (void) viewDidAppear:(BOOL)animated
{
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
	UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(28, 15, STAR_SIZE, STAR_SIZE)] autorelease];
	label.text = @"*";
	label.backgroundColor = [UIColor clearColor];
	label.textColor = [UIColor redColor];
	label.font = [UIFont boldSystemFontOfSize:STAR_SIZE];

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

- (UITableViewCell *) createDetailCellFor:(UITableView *)tableView at:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:FOOD_DETAIL_TITLE[indexPath.row]];
	
	if (cell == nil) 
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2
					       reuseIdentifier:FOOD_DETAIL_TITLE[indexPath.row]] 
			autorelease];
		cell.textLabel.textColor = [Color grey2Color];
		cell.textLabel.font = [UIFont systemFontOfSize:13.0];
		cell.textLabel.text = FOOD_DETAIL_TITLE[indexPath.row];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		if (nil == gs_food_detail_text_view[indexPath.row])
		{
			CGFloat X = 75.0;
			CGFloat Y = 0.0;
			CGFloat width = cell.contentView.frame.size.width - X - 28.0;
			CGFloat height = 44;
			gs_food_detail_text_view[indexPath.row] = [[UITextField alloc] initWithFrame:CGRectMake(X, 
														Y, 
														width, 
														height)];
			gs_food_detail_text_view[indexPath.row].center = CGPointMake(gs_food_detail_text_view[indexPath.row].center.x, cell.center.y);
			gs_food_detail_text_view[indexPath.row].font = [UIFont systemFontOfSize:FONT_SIZE];
			gs_food_detail_text_view[indexPath.row].delegate = self;
			gs_food_detail_text_view[indexPath.row].contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
			gs_food_detail_text_view[indexPath.row].returnKeyType = UIReturnKeyDone;
			
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
	
	if (FOOD_PLACE == indexPath.row)
	{
		[self updateCity];
	}
	
	return cell;
}

- (UITableViewCell *) createDescCellFor:(UITableView *)tableView at:(NSIndexPath *)indexPath
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
											      88)];
			gs_food_desc_text_view.scrollEnabled = NO;
			gs_food_desc_text_view.backgroundColor = [UIColor clearColor];
			gs_food_desc_text_view.font = [UIFont systemFontOfSize:FONT_SIZE];
			gs_food_desc_text_view.delegate = self;
		}
		
		[cell.contentView addSubview:gs_food_desc_text_view];
	}
	
	return cell;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch (indexPath.section) 
	{
	case FOOD_DETAIL:
		return [self createDetailCellFor:tableView at:indexPath];

		break;
	case FOOD_DESC:
		return [self createDescCellFor:tableView at:indexPath];

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
		case FOOD_HEADER:
			return self.header.view;
			
			break;
		default:
			return nil;
			break;
	}
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	switch (section) 
	{
		case FOOD_HEADER:
			return 416;

			break;
		case FOOD_DESC:
			return 28.0;

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
			frame.size.height = MAX(gs_food_desc_text_view.contentSize.height, 88);
			gs_food_desc_text_view.frame = frame;
			gs_food_desc_text_view.text = descString;

			return frame.size.height;
		}
		break;

	default:
		return 44;
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
			[self updateShareButton];
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
		if (0 >= gs_food_detail_text_view[FOOD_CITY].text.length)
		{
			[self requestUserCity];
		}
	}
}

- (void) resetImageWithUploadFileID:(NSInteger)fileID;
{
	@autoreleasepool 
	{
		self.uploadingID = [NSNumber numberWithInteger:fileID];
	}
}

- (BOOL) checkParamsReady
{
	BOOL paramsReady = YES;

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
	
	if (nil == self.header.image.picID)
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
	NSNumber *uploadID = [result valueForKey:@"id"];
	
	if (CHECK_EQUAL(self.uploadingID ,uploadID))
	{
		NSNumber *picID = [[result valueForKey:@"result"] valueForKey:@"id"];
		
		[self.header setImageID:picID];
		
		self.uploadingID = nil;
		[self updateShareButton];
	}
}

- (void) createFood:(id)sender
{
	if ([self checkParamsReady])
	{
		NSMutableDictionary *params = [[NSMutableDictionary alloc] init];

		[params setValue:gs_food_detail_text_view[FOOD_NAME].text forKey:@"name"];
		[params setValue:gs_food_detail_text_view[FOOD_CITY] forKey:@"city"];
		[params setValue:gs_food_detail_text_view[FOOD_PLACE].text forKey:@"place_name"];
		[params setValue:gs_food_desc_text_view.text forKey:@"desc"];
		[params setValue:self.header.image.picID forKey:@"pic"];
		[params setValue:[gs_food_detail_text_view[FOOD_TAG].text componentsSeparatedByString:@" "] forKey:@"category"];
		[params setValue:[NSNumber numberWithFloat:[self.header.score.text floatValue]]  forKey:@"taste_score"];
		[params setValue:[NSNumber numberWithBool:self.header.special.selected]  forKey:@"like_special"];
		[params setValue:[NSNumber numberWithBool:self.header.valued.selected]  forKey:@"like_valued"];
		[params setValue:[NSNumber numberWithBool:self.header.health.selected]  forKey:@"like_healthy"];

		[FoodManager createFood:params withHandler:@selector(foodCreated:) andTarget:self];
		
		self.navigationItem.rightBarButtonItem.enabled = NO;

		[params release];
	}
	
	[self dismissModalViewControllerAnimated:YES];
}

- (void) cancelCreate:(id)sender
{
	[self.header cleanHeader];
	
	self.uploadingID = nil;
	
	[self.navigationController popToRootViewControllerAnimated:NO];

	[self dismissModalViewControllerAnimated:YES];
}

- (void) foodCreated:(id)result
{
	@autoreleasepool 
	{
		[self.header cleanHeader];

		for (int i = 0; i < NEW_FOOD_DETAIL_MAX; ++i)
		{
			if (FOOD_PLACE == i)
			{
				// Do not clean city text
				continue;
			}

			gs_food_detail_text_view[i].text = @"";
		}

		gs_food_desc_text_view.text = @"";
		
		[self.navigationController popToRootViewControllerAnimated:NO];
		
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

	for ( i = 0; i < NEW_FOOD_DETAIL_MAX; ++i)
	{
		if ([gs_food_detail_text_view[i] isFirstResponder])
		{
			[textField resignFirstResponder];

			break;
		}
	}

	return YES;
}

- (void) textFieldDidBeginEditing:(UITextField *)textField
{
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
	[self updateShareButton];
}

- (void) showALlTextField
{
	[self.tableView setContentOffset:TEXT_OFFSET animated:YES];
}

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
	if (gs_food_detail_text_view[FOOD_PLACE] != textField)
	{
		[self performSelector:@selector(showALlTextField) withObject:nil afterDelay:0.5];
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
