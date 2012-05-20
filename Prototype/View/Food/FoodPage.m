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

@interface FoodPage () <TextInputerDeletgate, ShowVCDelegate>
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

#pragma mark - life circle

- (id) init
{
	self = [super init];

	if (self) 
	{
		self.refreshStyle = PULL_TO_REFRESH_STYLE_WHITE;
	}
	
	return self;
}

- (void) didReceiveMemoryWarning
{
	if (self.inputer.appearing)
	{
		[self cancelWithTextInputer:self.inputer];
	}

	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];
}

- (void) dealloc
{
	self.inputer = nil;
	self.navco = nil;
	self.titleView = nil;
	self.foodInfo = nil;
	
	[super dealloc];
}

#pragma mark - View lifecycle

- (void) viewWillAppear:(BOOL)animated
{	
	[super viewWillAppear:animated];
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
			
			self.lastRowCount = commentCount;

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
				    backColor:[Color orange] 
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
		[moreComment setBackgroundColor:[Color lightyellow]];
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
		cell.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, DEFAULT_CELL_HEIGHT);
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
			return DEFAULT_CELL_HEIGHT;
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

#pragma mark - textInputerDelegate

- (void) inputComment:(id)sender
{
	@autoreleasepool 
	{
		[self dismissModalViewControllerAnimated:YES];
		[self presentModalViewController:self.navco animated:YES];
	}
}

- (void) textDoneWithTextInputer:(TextInputer *)inputer
{
	NSString *foodID = [[self.foodObject valueForKey:@"id"] stringValue];

	[self dismissModalViewControllerAnimated:YES];
	[FoodCommentMananger createComment:inputer.text.text 
				   forList:foodID 
			       withHandler:@selector(createCommentHandler:) 
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

#pragma mark - GUI

- (void) reloadCommentSection
{
	NSString *foodID = [[self.foodObject valueForKey:@"id"] stringValue];
	NSUInteger commentCount = [[FoodCommentMananger keyArrayForList:foodID] count];
	static NSMutableIndexSet *commentSectionSet = nil;
	
	if (nil == commentSectionSet)
	{
		commentSectionSet = [[NSMutableIndexSet alloc] init];
		[commentSectionSet addIndex:FOOD_COMMENT];
		[commentSectionSet addIndex:FOOD_MORE];
	}
	
	if (self.lastRowCount != commentCount) 
	{
		[self.tableView reloadSections:commentSectionSet withRowAnimation:UITableViewRowAnimationFade];
	}
	
	[self.refreshHeader egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}

- (void) backToPrevView
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (void) initGUI
{
	@autoreleasepool 
	{
		[super initGUI];

		if (nil == self.titleView)
		{
			self.titleView = [[[TitleVC alloc] init] autorelease];
		}
		self.navigationItem.titleView = self.titleView.view;
		
		if (nil == self.inputer)
		{
			self.inputer = [[[TextInputer alloc] init] autorelease];
			self.inputer.delegate = self;
			self.inputer.title = @"添加评论";
		}
		
		if (nil == self.navco)
		{
			self.navco = [[[UINavigationController alloc] initWithRootViewController:
				       self.inputer] autorelease];
			CONFIG_NAGIVATION_BAR(self.navco.navigationBar);
		}
		
		self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		self.view.backgroundColor = [Color brown];
		
		self.navigationItem.leftBarButtonItem = SETUP_BACK_BAR_BUTTON(self, 
									      @selector(backToPrevView));
		
		self.navigationItem.rightBarButtonItem = SETUP_BAR_BUTTON([UIImage imageNamed:@"comIcon.png"], 
									  self, 
									  @selector(inputComment:));
	}
}

- (void) reload
{
	self.titleView.object = self.foodObject;
	
	[self.tableView reloadData];
}

#pragma mark - object manange

- (void) refreshFood
{
	self.foodObject = [FoodManager getObjectWithNumberID:[self.foodObject valueForKey:@"id"]];
	
	[self reload];
}

- (void) requestFood
{
	NSNumber *foodID = [self.foodObject valueForKey:@"id"];
	
	if (nil != foodID)
	{
		[FoodManager requestObjectWithNumberID:foodID
					    andHandler:@selector(refreshFood) 
					     andTarget:self];
	}
}

- (void) requestNewestComment
{
	NSString *foodID = [[self.foodObject valueForKey:@"id"] stringValue];
	[FoodCommentMananger requestNewestWithListID:foodID 
					    andCount:COMMENT_REFRESH_WINDOW 
					 withHandler:@selector(reloadCommentSection) 
					   andTarget:self];
}

- (void) requestNewerComment
{	
	NSString *foodID = [[self.foodObject valueForKey:@"id"] stringValue];
	[FoodCommentMananger requestNewerWithListID:foodID 
					   andCount:COMMENT_REFRESH_WINDOW 
					withHandler:@selector(reloadCommentSection) 
					  andTarget:self];
}

- (void) requestOlderComment
{
	NSString *foodID = [[self.foodObject valueForKey:@"id"] stringValue];
	[FoodCommentMananger requestOlderWithListID:foodID 
					   andCount:COMMENT_REFRESH_WINDOW 
					withHandler:@selector(reloadCommentSection) 
					  andTarget:self];
}

- (void) setFoodObject:(NSDictionary *)foodObject
{
	if (CHECK_EQUAL(_foodObject ,foodObject))
	{
		return;
	}
	
	[_foodObject release];
	_foodObject = [foodObject retain];
}

- (void) createCommentHandler:(id)result
{
	[self requestNewestComment];
	[self reloadCommentSection];
}

- (void) pullToRefreshRequest
{
	[self requestFood];
	[self requestNewestComment];
}

- (void) requestNewer
{
	[self requestNewerComment];
}

- (void) requestOlder
{
	[self requestOlderComment];
}

- (BOOL) isUpdating
{
	return [FoodCommentMananger isUpdatingWithType:REQUEST_NEWEST 
					    withListID:[[self.foodObject valueForKey:@"user"] stringValue]];
}
- (NSDate* ) lastUpdateDate
{
	return [FoodCommentMananger lastUpdatedDateForList:[[self.foodObject valueForKey:@"id"] stringValue]];
}

@end
