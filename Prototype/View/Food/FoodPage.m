//
//  FoodPage.m
//  Prototype
//
//  Created by Adrian Lee on 12/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "FoodPage.h"

#import "FoodInfo.h"
#import "FoodCommentMananger.h"
#import "CommentCell.h"
#import "DescriptionCell.h"
#import "Util.h"
#import "TextInputer.h"
#import "TitleVC.h"
#import "FoodTagCell.h"
#import "TriangleCell.h"
#import "FoodManager.h"

const static uint32_t COMMENT_REFRESH_WINDOW = 5;
const static CGFloat IMAGE_SIZE = 320.0;
const static CGFloat FONT_SIZE = 12.0;

typedef enum FOOD_PAGE_SECTION_ENUM
{
	FOOD_INFO = 0x0,
	FOOD_DESC = 0x1,
	FOOD_COMMENT = 0x2,
	FOOD_MORE = 0x3,
	FOOD_SECTION_MAX,
// TODO: Evaluate to show tags
	FOOD_TAG = 0xFFFF,
} FOOD_PAGE_SECTION;

@interface FoodPage () <UIScrollViewDelegate, TextInputerDeletgate, ShowVCDelegate>
{
	NSDictionary *_foodObject;
	TextInputer *_inputer;
	UINavigationController *_navco;
	TitleVC *_titleView;
	FoodInfo *_foodInfo;
}

@property (strong, nonatomic) TextInputer *inputer;
@property (strong, nonatomic) UINavigationController *navco;
@property (strong, nonatomic) TitleVC *titleView;
@property (strong, nonatomic) FoodInfo *foodInfo;
@end

@implementation FoodPage

@synthesize foodObject = _foodObject;
@synthesize inputer = _inputer;
@synthesize navco = _navco;
@synthesize titleView = _titleView;
@synthesize foodInfo = _foodInfo;

#pragma mark - util

static int32_t s_lastCommentArrayCount = -1;

- (void) refreshCommentSection
{
	NSString *foodID = [[self.foodObject valueForKey:@"id"] stringValue];
	NSUInteger commentArrayCount = [[FoodCommentMananger keyArrayForList:foodID] count];
	static NSMutableIndexSet *commentSectionSet = nil;
	
	if (nil == commentSectionSet)
	{
		commentSectionSet = [[NSMutableIndexSet alloc] init];
		[commentSectionSet addIndex:FOOD_COMMENT];
		[commentSectionSet addIndex:FOOD_MORE];
	}
	
	if (s_lastCommentArrayCount < commentArrayCount) 
	{
		[self.tableView reloadSections:commentSectionSet withRowAnimation:UITableViewRowAnimationFade];
		
		s_lastCommentArrayCount = commentArrayCount;
	}
}


- (void) forceRefreshTableView
{	
	NSString *foodID = [[self.foodObject valueForKey:@"id"] stringValue];
	NSUInteger commentArrayCount = [[FoodCommentMananger keyArrayForList:foodID] count];
	
	[self.tableView reloadData];
	
	s_lastCommentArrayCount = commentArrayCount;
}

- (void) updateGUI
{
	[self forceRefreshTableView];
	
	[self requestNewerComment];
}

#pragma mark message

- (void) requestNewerComment
{	
	NSString *foodID = [[self.foodObject valueForKey:@"id"] stringValue];
	[FoodCommentMananger requestNewerWithListID:foodID 
					   andCount:COMMENT_REFRESH_WINDOW 
					withHandler:@selector(refreshCommentSection) 
					  andTarget:self];
}

- (void) requestOlderComment
{
	NSString *foodID = [[self.foodObject valueForKey:@"id"] stringValue];
	[FoodCommentMananger requestOlderWithListID:foodID 
					   andCount:COMMENT_REFRESH_WINDOW 
					withHandler:@selector(refreshCommentSection) 
					  andTarget:self];
}

#pragma mark - life circle

- (id) initWithStyle:(UITableViewStyle)style
{
	self = [super initWithStyle:style];

	if (self) 
	{
		self.titleView = [[[TitleVC alloc] init] autorelease];

		self.inputer = [[[TextInputer alloc] init] autorelease];
		self.inputer.delegate = self;
		self.inputer.title = @"添加评论";
		[self.inputer redraw];

		self.navco = [[[UINavigationController alloc] initWithRootViewController:
			       self.inputer] autorelease];
		CONFIG_NAGIVATION_BAR(self.navco.navigationBar);

	}
	return self;
}

- (void) didReceiveMemoryWarning
{
	if (self.navigationController.visibleViewController 
	    == self.navigationController.topViewController)
	{
		// Releases the view if it doesn't have a superview.
		[super didReceiveMemoryWarning];
	}
}

- (void) dealloc
{
	self.foodObject = nil;
	self.inputer = nil;
	self.navco = nil;
	self.titleView = nil;
	self.foodInfo = nil;
	
	[super dealloc];
}

#pragma mark - food objet

- (void) setFoodObject:(NSDictionary *)foodObject
{
	if ([_foodObject isEqualToDictionary:foodObject])
	{
		return;
	}
	
	[_foodObject release];
	_foodObject = [foodObject retain];
	
	self.titleView.object = self.foodObject;
}

#pragma mark - View lifecycle

- (void) backToPrevView
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (void) setupView
{
	@autoreleasepool 
	{
		self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		self.view.backgroundColor = [Color brownColor];

		self.navigationItem.leftBarButtonItem = SETUP_BACK_BAR_BUTTON(self, 
									      @selector(backToPrevView));
		
		self.navigationItem.rightBarButtonItem = SETUP_BAR_BUTTON([UIImage imageNamed:@"comIcon.png"], 
									  self, 
									  @selector(inputComment:));
		
		self.navigationItem.titleView = self.titleView.view;
	}
}

- (void) viewDidLoad
{
	[super viewDidLoad];
	
	[self setupView];
}

- (void) viewDidUnload
{
	[super viewDidUnload];
	
	self.foodObject = nil;
	self.inputer = nil;
	self.navco = nil;
	self.titleView = nil;
	self.foodInfo = nil;
}

- (void) viewWillAppear:(BOOL)animated
{	
	[super viewWillAppear:animated];
	
	[self updateGUI];
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
		{
			NSString *foodID = [[self.foodObject valueForKey:@"id"] stringValue];
			NSUInteger commentCount = [[FoodCommentMananger keyArrayForList:foodID] count];

			if (0 < commentCount) 
			{
				return commentCount + 1;
			}
			else 
			{
				return 0;
			}
		}
			break;
		case FOOD_MORE:
		{
			NSString *foodID = [[self.foodObject valueForKey:@"id"] stringValue];
			NSInteger loadedComment =  [[FoodCommentMananger keyArrayForList:foodID] count];
			NSInteger totalComment = [[self.foodObject valueForKey:@"comment_count"] intValue];
			
			if (loadedComment < totalComment)
			{
				return 1;
			}
			else 
			{
				return 0;
			}
		}
			break;
			
		case FOOD_TAG:
			if (1 < [[self.foodObject valueForKey:@"tags"] count])
			{
				return 1;
			}
			else 
			{
				return 0;
			}
			break;
		default:
			return 1;
			break;
	}
}

- (UITableViewCell *) getInfoCellFor:(UITableView *)tableView index:(NSIndexPath *)indexPath
{
	static NSString *userCellIndentifier = @"FoodUserCell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:userCellIndentifier];
	
	if (nil == self.foodInfo)
	{
		self.foodInfo = [[[FoodInfo alloc] init] autorelease];
		self.foodInfo.delegate = self;
	}
	
	if (nil == cell)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
					       reuseIdentifier:userCellIndentifier] 
			autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		[cell.contentView addSubview:self.foodInfo.view];
	}
	
	self.foodInfo.food = self.foodObject;
	
	return cell;
}

- (UITableViewCell *) getDescCellFor:(UITableView *)tableView index:(NSIndexPath *)indexPath
{
	static NSString *descCellIdentifier = @"descriptionCell";
	
	DescriptionCell *cell = [tableView dequeueReusableCellWithIdentifier:descCellIdentifier];
	if (nil == cell) 
	{
		cell = [[[DescriptionCell alloc] 
			 initWithStyle:UITableViewCellStyleDefault 
			 reuseIdentifier:descCellIdentifier] 
			autorelease];
		cell.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, 40.0);
	}
	
	cell.objectDict = self.foodObject;
	
	return cell;
}

- (UITableViewCell *) getCommentCellFor:(UITableView *)tableView index:(NSIndexPath *)indexPath
{
	// row 0 for triangle cell 
	if (1 <= indexPath.row)
	{
		static NSString *commentCellIdentifier = @"commentCell";
		CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:commentCellIdentifier];

		if (nil == cell) 
		{
			cell = [[[CommentCell alloc] 
				initWithStyle:UITableViewCellStyleDefault 
			      reuseIdentifier:commentCellIdentifier] 
			      autorelease];
			cell.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, 60.0);
			cell.delegate = self;
		}

		NSString *foodID = [[self.foodObject valueForKey:@"id"] stringValue];
		NSArray * keyArray = [FoodCommentMananger keyArrayForList:foodID];
		NSString *commentID = [keyArray objectAtIndex:indexPath.row - 1];
		cell.commentDict = [FoodCommentMananger getObject:commentID inList:foodID];

		return cell;
	}
	else 
	{
		static NSString *triangleCellIndentifier = @"triangleCell";
		TriangleCell *cell = [tableView dequeueReusableCellWithIdentifier:triangleCellIndentifier];

		if (nil == cell)
		{
			cell = [[[TriangleCell alloc] 
				initWithStyle:UITableViewCellStyleDefault 
			      reuseIdentifier:triangleCellIndentifier
				    backColor:[Color orangeColor] 
				triangleColor:[UIColor whiteColor]
				] autorelease];
		}

		return cell;
	}
}

- (UITableViewCell *) getMoreCellFor:(UITableView *)tableView index:(NSIndexPath *)indexPath
{
	static NSString *moreCellIdentifier = @"moreCommentCell";

	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:moreCellIdentifier];

	if (nil == cell)
	{
		cell = [[[UITableViewCell  alloc] initWithStyle:UITableViewCellStyleDefault 
						reuseIdentifier:moreCellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;

		CGRect buttonFrame = CGRectMake(0, 0, self.view.frame.size.width, 40.0);
		UIButton *moreComment = [[UIButton alloc] initWithFrame:buttonFrame];

		moreComment.titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE];
		[moreComment setTitle:@"更多评论" forState:UIControlStateNormal];
		[moreComment setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		[moreComment setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
		[moreComment setBackgroundColor:[Color lightyellowColor]];
		[moreComment addTarget:self 
				action:@selector(requestOlderComment) 
		      forControlEvents:UIControlEventTouchUpInside];

		[cell.contentView addSubview:moreComment];

		[moreComment release];
	}

	return cell;
}

- (UITableViewCell *) getTagCellFor:(UITableView *)tableView index:(NSIndexPath *)indexPath
{
	static NSString *tagCellIdentifier = @"foodTagCell";

	FoodTagCell *cell = [tableView dequeueReusableCellWithIdentifier:tagCellIdentifier];

	if (cell == nil) 
	{
		cell = [[[FoodTagCell alloc] 
			initWithStyle:UITableViewCellStyleDefault 
		      reuseIdentifier:tagCellIdentifier] 
		      autorelease];
		cell.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, 44.0);
	}

	if (nil  != self.foodObject)
	{
		cell.foodObject = self.foodObject;
	}

	return cell;
}


- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch (indexPath.section) 
	{
		case FOOD_INFO:
			return [self getInfoCellFor:tableView index:indexPath];

			break;
		case FOOD_DESC:
			return [self getDescCellFor:tableView index:indexPath];

			break;

		case FOOD_COMMENT:
			return [self getCommentCellFor:tableView index:indexPath];

			break;
		case FOOD_MORE:
			return [self getMoreCellFor:tableView index:indexPath];

			break;
		case FOOD_TAG:
			return [self getTagCellFor:tableView index:indexPath];

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
		case FOOD_INFO:
			return 367.0;
			break;
		case FOOD_DESC:
		{
			return [DescriptionCell cellHeightForObject:self.foodObject forCellWidth:self.view.frame.size.width];
		}
			break;
		case FOOD_COMMENT:
		{
			// row 0 for triangle cell
			if (1 <= indexPath.row)
			{
				NSString *foodID = [[self.foodObject valueForKey:@"id"] stringValue];
				NSArray * keyArray = [FoodCommentMananger keyArrayForList:foodID];
				NSString *commentID = [keyArray objectAtIndex:indexPath.row - 1];
				NSDictionary *comment = [FoodCommentMananger getObject:commentID inList:foodID];
				return [CommentCell cellHeightForComment:comment forCellWidth:self.view.frame.size.width];
			}
			else 
			{
				return 10.0;
			}
		}
			break;
		case FOOD_MORE:
			return 40.0;
		case FOOD_TAG:
			return [FoodTagCell cellHeightForObject:self.foodObject forCellWidth:self.view.frame.size.width];
		default:
			return 44.0;
	}
	
}

#pragma mark - Table view delegate

- (NSIndexPath *) tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	return nil;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void) tableView:(UITableView *)tableView 
   willDisplayCell:(UITableViewCell *)cell 
 forRowAtIndexPath:(NSIndexPath *)indexPath
{
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
	[self refreshCommentSection];
}

#pragma mark - textInputerDelegate

- (void) inputComment:(id)sender
{
	@autoreleasepool 
	{
		[self presentModalViewController:self.navco animated:YES];
		[self dismissModalViewControllerAnimated:YES];
	}
}

- (void) textDoneWithTextInputer:(TextInputer *)inputer
{
	NSString *foodID = [[self.foodObject valueForKey:@"id"] stringValue];
	[self dismissModalViewControllerAnimated:YES];
	[FoodCommentMananger createComment:inputer.text.text 
				   forList:foodID 
			       withHandler:@selector(newCommentHandler:) 
				 andTarget:self];
}

- (void) cancelWithTextInputer:(TextInputer *)inputer
{
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark - FoodInfoDelegate

- (void) showVC:(UIViewController *)VC
{
	[self.navigationController pushViewController:VC animated:YES];
}

@end
