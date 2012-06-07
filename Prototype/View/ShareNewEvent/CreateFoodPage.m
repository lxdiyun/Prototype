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
#import "AppDelegate.h"
#import "InputMapPage.h"

const static CGFloat  FONT_SIZE = 15.0;
const static CGFloat STAR_SIZE = 22;
static CGPoint DETAIL_OFFSET = {0, 0};

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

static UITextView *gs_food_detail_text_view[NEW_FOOD_DETAIL_MAX] = {nil};
static UITextView *gs_food_desc_text_view = nil;
static UILabel *gs_food_detail_star_label[NEW_FOOD_DETAIL_MAX] = {nil};
static TextInputer *gs_food_desc_inputer =  nil;
static TagSelector *gs_tag_selector = nil;

@interface CreateFoodPage () <UITextViewDelegate, TextInputerDeletgate, InputMapDelegate, TagSelectorDelegate>
{
	CreateFoodHeaderVC *_header;
	NSNumber *_uploadingID;
	CreateFoodTask *_task;
	InputMapPage *_inputMap;
	
}
- (void) updateCity;
- (BOOL) checkParamsReady;

@property (strong, nonatomic) CreateFoodHeaderVC *header;
@property (strong, nonatomic) NSNumber *uploadingID;
@property (strong, nonatomic) InputMapPage *inputMap;
@end

@implementation CreateFoodPage

@synthesize header = _header;
@synthesize uploadingID = _uploadingID;
@synthesize task = _task;
@synthesize inputMap = _inputMap;

- (id) initWithStyle:(UITableViewStyle)style
{
	self = [super initWithStyle:UITableViewStyleGrouped];
	if (self) 
	{
		@autoreleasepool 
		{
			self.view.backgroundColor = [Color lightyellow];
			self.header = [[[CreateFoodHeaderVC alloc] init] autorelease];
			self.title = @"分享美食";
			DETAIL_OFFSET.y = self.header.view.frame.size.height;
			
			self.inputMap = [[[InputMapPage alloc] init] autorelease];
			self.inputMap.delegate = self;
		}
	}
	return self;
}

- (void) cleanData
{
	self.header = nil;
	self.uploadingID = nil;
	self.task = nil;
	self.inputMap = nil;
	
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

	self.navigationItem.rightBarButtonItem = SETUP_BAR_TEXT_BUTTON(@"分享", self, @selector(createFoodEtc:));

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
		cell.textLabel.textColor = [Color grey2];
		cell.textLabel.font = [UIFont systemFontOfSize:13.0];
		cell.textLabel.text = FOOD_DETAIL_TITLE[indexPath.row];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		if (nil == gs_food_detail_text_view[indexPath.row])
		{
			CGFloat X = 75.0;
			CGFloat Y = 4.0;
			CGFloat width = cell.contentView.frame.size.width - X - 28.0;
			CGFloat height = FONT_SIZE * 2;
			gs_food_detail_text_view[indexPath.row] = [[UITextView alloc] initWithFrame:CGRectMake(X, 
													       Y, 
													       width, 
													       height)];
			gs_food_detail_text_view[indexPath.row].font = [UIFont systemFontOfSize:FONT_SIZE];
			gs_food_detail_text_view[indexPath.row].delegate = self;
			gs_food_detail_text_view[indexPath.row].returnKeyType = UIReturnKeyDone;
			gs_food_detail_text_view[indexPath.row].backgroundColor = [UIColor clearColor];
			gs_food_detail_text_view[indexPath.row].scrollEnabled = NO;
			
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
			return self.header.view.frame.size.height;

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
	switch (indexPath.section) 
	{
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
			return DEFAULT_CELL_HEIGHT;
			break;
	}
}

#pragma mark - GUI

- (void) rollToDetail
{
	[self.tableView setContentOffset:DETAIL_OFFSET animated:YES];
}

- (void) resetImage:(UIImage *)image;
{
	@autoreleasepool 
	{
		self.header.image.image = image;
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

#pragma mark - object manager

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

- (void) createFoodEtc:(id)sender
{
	if ([self checkParamsReady])
	{
		NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
		
		NSString *city = gs_food_detail_text_view[FOOD_CITY].text;
		

		[params setValue:gs_food_detail_text_view[FOOD_NAME].text forKey:@"name"];
		[params setValue:city forKey:@"city"];
		[params setValue:gs_food_desc_text_view.text forKey:@"desc"];
//		[params setValue:[gs_food_detail_text_view[FOOD_TAG].text componentsSeparatedByString:@" "] forKey:@"category"];
		[params setValue:[NSNumber numberWithFloat:[self.header.score.text floatValue]]  forKey:@"taste_score"];
		[params setValue:[NSNumber numberWithBool:self.header.special.selected]  forKey:@"like_special"];
		[params setValue:[NSNumber numberWithBool:self.header.valued.selected]  forKey:@"like_valued"];
		[params setValue:[NSNumber numberWithBool:self.header.health.selected]  forKey:@"like_healthy"];
		[params setValue:[NSNumber numberWithBool:self.header.weibo.selected]  forKey:@"post_weibo"];

		[self.task etcReady:params];
		
		self.inputMap.placeName = gs_food_detail_text_view[FOOD_PLACE].text;
		self.inputMap.city = city;
		
		[self.navigationController pushViewController:self.inputMap animated:YES];
		
		[params release];
	}
}

- (void) cancelCreate:(id)sender
{
	[self.header cleanHeader];
	
	[self.task cancel];

	self.task = nil;
	
	self.uploadingID = nil;
	
	[self.navigationController popToRootViewControllerAnimated:NO];

	[self dismissModalViewControllerAnimated:YES];
}

- (void) foodCreated
{
	@autoreleasepool 
	{
		[self dismissModalViewControllerAnimated:YES];

		[self.header cleanHeader];
		
		for (int i = 0; i < NEW_FOOD_DETAIL_MAX; ++i)
		{
			if (FOOD_PLACE == i)
			{
				// Do not clean city and place text
				continue;
			}

			gs_food_detail_text_view[i].text = @"";
		}

		gs_food_desc_text_view.text = @"";
		
		[self.navigationController popToRootViewControllerAnimated:NO];
		[self resetImage:nil];
		self.task = nil;
		
		[self updateShareButton];
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
	}

	gs_food_desc_inputer.text.text = gs_food_desc_text_view.text;


	PUSH_VC(self.navigationController, gs_food_desc_inputer, YES);
}

- (void) dismissKeyboard
{
	for (NSInteger i = 0; i < NEW_FOOD_DETAIL_MAX; ++i)
	{
		if ([gs_food_detail_text_view[i] isFirstResponder])
		{
			[gs_food_detail_text_view[i] resignFirstResponder];
			
			break;
		}
	}
}

#pragma mark - UITextViewDelegate

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
	if (gs_food_desc_text_view == textView)
	{
		[self showTextInputer];
		
		return NO;
	}
	
	if (gs_food_detail_text_view[FOOD_PLACE] != textView)
	{
		[self performSelector:@selector(rollToDetail) withObject:nil afterDelay:0.5];
	}

	return YES;
}

- (void) textViewDidChange:(UITextView *)textView
{
	[self updateShareButton];
}

- (BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
	if ([text isEqualToString:@"\n"]) 
	{
		[textView resignFirstResponder];
		return NO;
	}

	NSUInteger newLength = [textView.text length] + [text length] - range.length;
	
	return (newLength > MAX_TEXT_LENGTH) ? NO : YES;
}

#pragma mark - TextInputerDeletgate

- (void) textDoneWithTextInputer:(TextInputer *)inputer
{
	gs_food_desc_text_view.text = inputer.text.text;
	inputer.text.text = nil;
	POP_VC(self.navigationController, YES);
	[self.tableView reloadData];
	[gs_food_desc_text_view resignFirstResponder];

	[self updateShareButton];
}

- (void) cancelWithTextInputer:(TextInputer *)inputer
{
	POP_VC(self.navigationController, YES);
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

	POP_VC(self.navigationController, YES);
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

#pragma mark - InputMapDelegate

- (void) placeSelected:(CLLocationCoordinate2D)coordinate
{
	NSMutableDictionary *place = [[NSMutableDictionary alloc] init];
	
	[place setValue:gs_food_detail_text_view[FOOD_PLACE].text forKey:@"name"];
	[place setValue:[NSNumber numberWithFloat:coordinate.latitude] forKey:@"lat"];
	[place setValue:[NSNumber numberWithFloat:coordinate.longitude] forKey:@"lng"];
	
	[self.task placeSelected:place];
	
	[place release];
	
	[self foodCreated];
}

@end
