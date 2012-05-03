//
//  FoodPage.m
//  Prototype
//
//  Created by Adrian Lee on 12/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "FoodPage.h"

#import "FoodUserCell.h"
#import "FoodImageCell.h"
#import "FoodCommentMananger.h"
#import "CommentCell.h"
#import "DescriptionCell.h"
#import "Util.h"
#import "TextInputer.h"
#import "TitleVC.h"

const static uint32_t COMMENT_REFRESH_WINDOW = 8;
const static uint32_t ROW_TO_MORE_COMMENT_FROM_BOTTOM = 2;

typedef enum FOOD_PAGE_SECTION_ENUM
{
	FOOD_USER = 0x0,
	FOOD_PIC = 0x1,
	FOOD_DESC = 0x2,
	FOOD_COMMENT = 0x3,
	FOOD_SECTION_MAX
} FOOD_PAGE_SECTION;

@interface FoodPage () <UIScrollViewDelegate, TextInputerDeletgate>
{
	NSDictionary *_foodDict;
	NSString *_foodID;
	TextInputer *_inputer;
	UINavigationController *_navco;
	TitleVC *_titleView;
	FoodUserCell *_foodUser;
}

@property (strong) NSString *foodID;
@property (strong, nonatomic) TextInputer *inputer;
@property (strong, nonatomic) UINavigationController *navco;
@property (strong, nonatomic) TitleVC *titleView;
@property (strong, nonatomic) FoodUserCell *foodUser;
@end

@implementation FoodPage

@synthesize foodDict = _foodDict;
@synthesize foodID = _foodID;
@synthesize inputer = _inputer;
@synthesize navco = _navco;
@synthesize titleView = _titleView;
@synthesize foodUser = _foodUser;

#pragma mark - util
static int32_t s_lastCommentArrayCount = -1;

- (void) refreshTableView:(id)result
{
	int32_t commentArrayCount = [[FoodCommentMananger keyArrayForList:self.foodID] count];

	if (s_lastCommentArrayCount < commentArrayCount) 
	{
		[self.tableView reloadData];
		
		s_lastCommentArrayCount = commentArrayCount;
	}
}

- (void) forceRefreshTableView
{
	s_lastCommentArrayCount = -1;
	
	[self refreshTableView:nil];
}

#pragma mark message

- (void) requestNewerCommentHandler:(id)result
{	
	[self refreshTableView:nil];
}

- (void) requestNewerComment
{	
	[FoodCommentMananger requestNewerWithListID:self.foodID 
					   andCount:COMMENT_REFRESH_WINDOW 
					withHandler:@selector(requestNewerCommentHandler:) 
					  andTarget:self];
}

- (void) requestOlderComment
{
	[FoodCommentMananger requestOlderWithListID:self.foodID 
					   andCount:COMMENT_REFRESH_WINDOW 
					withHandler:@selector(refreshTableView:) 
					  andTarget:self];
}

#pragma mark - life circle

- (id) initWithStyle:(UITableViewStyle)style
{
	self = [super initWithStyle:style];
	if (self) 
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
	self.foodDict = nil;
	self.foodID = nil;
	self.inputer = nil;
	self.navco = nil;
	self.titleView = nil;
	self.foodUser = nil;
	
	[super dealloc];
}

#pragma mark - View lifecycle

- (void) setupView
{
	@autoreleasepool 
	{
		
		self.navigationItem.leftBarButtonItem = SETUP_BACK_BAR_BUTTON(self.navigationController, 
									      @selector(popViewControllerAnimated:));
		
		self.navigationItem.rightBarButtonItem = SETUP_BAR_BUTTON([UIImage imageNamed:@"comIcon.png"], 
									  self, 
									  @selector(inputComment:));
		
		self.titleView = [[[TitleVC alloc] init] autorelease];
		
		self.navigationItem.titleView = self.titleView.view;
	}
}

- (void) viewDidLoad
{
	[super viewDidLoad];

	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.view.backgroundColor = [Color orangeColor];
	
	[self setupView];
}

- (void) viewDidUnload
{
	[super viewDidUnload];
	
	self.foodDict = nil;
	self.foodID = nil;
	self.inputer = nil;
	self.navco = nil;
	self.titleView = nil;
	self.foodUser = nil;
}

- (void) viewWillAppear:(BOOL)animated
{	
	self.titleView.name.text = [self.foodDict valueForKey:@"name"];
	self.titleView.placeName.text = [NSString stringWithFormat:@"@%@", 
					 [self.foodDict valueForKey:@"place_name"]];
	self.foodID = [[self.foodDict valueForKey:@"id"] stringValue];
	[self forceRefreshTableView];
	
	[super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated
{
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

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
	// Return the number of sections.
	return FOOD_SECTION_MAX;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	// Return the number of rows in the section.

	switch (section)
	{
		case FOOD_COMMENT:
			return [[FoodCommentMananger keyArrayForList:self.foodID] count];
			break;
		default:
			return 1;
			break;
	}
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch (indexPath.section) 
	{
		case FOOD_USER:
		{
			static NSString *userCellIndentifier = @"FoodUserCell";
			
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:userCellIndentifier];
			
			if (nil == self.foodUser)
			{
				self.foodUser = [[[FoodUserCell alloc] init] autorelease];
			}
			
			if (nil == cell)
			{
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:userCellIndentifier] autorelease];
				[cell.contentView addSubview:self.foodUser.view];
			}
			
			self.foodUser.food = self.foodDict;
			
			return cell;
		}
			break;
		case FOOD_PIC:
		{
			static NSString *imageCellIdentifier = @"FoodImageCell";
			
			FoodImageCell *cell = [tableView dequeueReusableCellWithIdentifier:imageCellIdentifier];
			if (cell == nil) 
			{
				cell = [[[FoodImageCell alloc] 
					 initWithStyle:UITableViewCellStyleDefault 
					 reuseIdentifier:imageCellIdentifier] 
					autorelease];
				cell.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.width);
				
				[cell redraw];
			}
			
			NSNumber *picID = [self.foodDict valueForKey:@"pic"];
			
			if (nil  != picID)
			{
				cell.foodImage.picID = picID;
			}
				return cell;
		}
			break;
		case FOOD_DESC:
		{
			static NSString *descCellIdentifier = @"descriptionCell";
			
			DescriptionCell *cell = [tableView dequeueReusableCellWithIdentifier:descCellIdentifier];
			if (cell == nil) 
			{
				cell = [[[DescriptionCell alloc] 
					 initWithStyle:UITableViewCellStyleDefault 
					 reuseIdentifier:descCellIdentifier] 
					autorelease];
				cell.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, 60.0 * PROPORTION());
			}
			
			cell.objectDict = self.foodDict;
			
			return cell;
		}
			break;

		case FOOD_COMMENT:
		{
			static NSString *commentCellIdentifier = @"commentCell";
			CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:commentCellIdentifier];;
			
			if (cell == nil) 
			{
				cell = [[[CommentCell alloc] 
					 initWithStyle:UITableViewCellStyleDefault 
					 reuseIdentifier:commentCellIdentifier] 
					autorelease];
				cell.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, 60.0 * PROPORTION());
			}
			
			NSArray * keyArray = [FoodCommentMananger keyArrayForList:self.foodID];
			NSString *commentID = [keyArray objectAtIndex:indexPath.row];
			cell.commentDict = [FoodCommentMananger getObject:commentID inList:self.foodID];
			return cell;
		}
			break;
			
		default:
			return nil;
			break;
	}
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	switch (indexPath.section) 
	{
		case FOOD_USER:
			return 44;
			break;
		case FOOD_PIC:
			return 320;
			break;
		case FOOD_DESC:
		{
			return [DescriptionCell cellHeightForObject:self.foodDict forCellWidth:self.view.frame.size.width];
		}
			break;
		case FOOD_COMMENT:
		{
			NSArray * keyArray = [FoodCommentMananger keyArrayForList:self.foodID];
			NSString *commentID = [keyArray objectAtIndex:indexPath.row];
			NSDictionary *comment = [FoodCommentMananger getObject:commentID inList:self.foodID];
			return [CommentCell cellHeightForComment:comment forCellWidth:self.view.frame.size.width];
		}
			break;
		default:
			return 60 * PROPORTION();
	}
	
}

#pragma mark - Table view delegate

- (NSIndexPath *) tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	return nil;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// Navigation logic may go here. Create and push another view controller.
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
	 // ...
	 // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
}

- (void) tableView:(UITableView *)tableView 
   willDisplayCell:(UITableViewCell *)cell 
 forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == FOOD_COMMENT)
	{
		uint32_t row = indexPath.row;
		uint32_t commentCount = [[FoodCommentMananger keyArrayForList:self.foodID] count];
		
		if (((commentCount - ROW_TO_MORE_COMMENT_FROM_BOTTOM) <= row) && (commentCount > 0))
		{
			[self requestOlderComment];
		}
	}
}

#pragma mark - UIScrollViewDelegate Methods

- (void) scrollViewDidScroll:(UIScrollView *)view
{	
	
}

- (void) scrollViewDidEndDragging:(UIScrollView *)view willDecelerate:(BOOL)decelerate
{
	
}

#pragma mark - NewComment handler

- (void) newCommentHandler:(id)result
{
	[self requestNewerComment];
	[self refreshTableView:nil];
}

#pragma mark - textInputerDelegate

- (void) inputComment:(id)sender
{
	@autoreleasepool 
	{
		if (nil == self.inputer)
		{
			self.inputer = [[[TextInputer alloc] init] autorelease];
			self.inputer.delegate = self;
			[self.inputer redraw];
		}
		
		if (nil == self.navco)
		{
			self.navco = [[[UINavigationController alloc] initWithRootViewController:self.inputer] autorelease];
			self.navco.navigationBar.barStyle = UIBarStyleBlack;
			self.inputer.title = @"添加评论";
		}
		
		[self presentModalViewController:self.navco animated:YES];
		[self dismissModalViewControllerAnimated:YES];
	}
}

- (void) textDoneWithTextInputer:(TextInputer *)inputer
{
	[self dismissModalViewControllerAnimated:YES];
	[FoodCommentMananger createComment:inputer.text.text 
				   forList:self.foodID 
			       withHandler:@selector(newCommentHandler:) 
				 andTarget:self];
}

- (void) cancelWithTextInputer:(TextInputer *)inputer
{
	[self dismissModalViewControllerAnimated:YES];
}


@end
