//
//  DetailFoodVC.m
//  Prototype
//
//  Created by Adrian Lee on 12/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DetailFoodVC.h"

#import "FoodInfo.h"
#import "FoodCommentMananger.h"
#import "CommentCell.h"
#import "DescriptionCell.h"
#import "Util.h"
#import "TextInputer.h"
#import "TitleVC.h"
#import "FoodTagCell.h"
#import "FoodManager.h"
#import "Seperator.h"

const static uint32_t COMMENT_REFRESH_WINDOW = 5;
const static CGFloat IMAGE_SIZE = 320.0;
const static CGFloat FONT_SIZE = 12.0;

typedef enum FOOD_PAGE_SECTION_ENUM
{
	FOOD_INFO = 0x0,
	FOOD_DESC = 0x1,
	SEPERATOR = 0x2,
	FOOD_COMMENT = 0x3,
	FOOD_MORE = 0x4,
	FOOD_SECTION_MAX,
// TODO: Evaluate to show tags
	FOOD_TAG = 0xFFFF,
} FOOD_PAGE_SECTION;

@interface DetailFoodVC () <FoodInfoDelegate>
{
	NSDictionary *_food;

	TitleVC *_titleView;
	FoodInfo *_foodInfo;
	NSNumber *_foodID;
	FoodPage<ShowVCDelegate> *_delegate;
	Seperator *_seperator;
}


@property (strong, nonatomic) TitleVC *titleView;
@property (strong, nonatomic) FoodInfo *foodInfo;
@property (strong, nonatomic) NSDictionary *food;
@property (strong, nonatomic) Seperator *seperator;
@end

@implementation DetailFoodVC

@synthesize food = _food;
@synthesize titleView = _titleView;
@synthesize foodInfo = _foodInfo;
@synthesize foodID = _foodID;
@synthesize seperator = _seperator;
@synthesize delegate = _delegate;

#pragma mark - life circle

- (id) init
{
	self = [super init];
	
	if (nil != self)
	{
		self.hidesBottomBarWhenPushed = YES;
	}
	
	return self;
}

- (void) didReceiveMemoryWarning
{
	if ([self.modalViewController isBeingPresented])
	{
		[self dismissModalViewControllerAnimated:YES];
	}

	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];
}

- (void) dealloc
{
	self.titleView = nil;
	self.foodInfo = nil;
	self.foodID = nil;
	self.seperator = nil;
	
	[super dealloc];
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
		case SEPERATOR:
		{
			NSInteger commentCount =  [self getCellCountFor:FOOD_COMMENT];
			NSInteger descCount =  [self getCellCountFor:FOOD_DESC];
			
			if ((0 < commentCount) && (0 < descCount))
			{
				return 1;
			}
			else 
			{
				return 0;
			}
		}
			break;

		case FOOD_MORE:
		{
			NSInteger loadedComment =  [self getCellCountFor:FOOD_COMMENT];
			NSInteger totalComment = [[self.food valueForKey:@"comment_count"] intValue];
			
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
			
		default:
			return [self getCellCountFor:section];
			
			break;
	}
}

- (UITableViewCell *) getInfoCellFor:(UITableView *)tableView index:(NSIndexPath *)indexPath
{
	static NSString *userCellIndentifier = @"FoodUserCell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:userCellIndentifier];
	
	if (nil == cell)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
					       reuseIdentifier:userCellIndentifier] 
			autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		[cell.contentView addSubview:self.foodInfo.view];
	}
	
	self.foodInfo.food = self.food;
	
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
	
	cell.objectDict = self.food;
	
	return cell;
}

- (UITableViewCell *) getCommentCellFor:(UITableView *)tableView index:(NSIndexPath *)indexPath
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

		NSArray * keyArray = [FoodCommentMananger keyArrayForList:[self.foodID stringValue]];
		NSString *commentID = [keyArray objectAtIndex:indexPath.row];
		cell.commentDict = [FoodCommentMananger getObject:commentID inList:[self.foodID stringValue]];

		return cell;
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

	if (nil  != self.food)
	{
		cell.foodObject = self.food;
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
			
		case SEPERATOR:
			return self.seperator;
			
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
			return self.foodInfo.view.frame.size.height;
			break;
		case FOOD_DESC:
		{
			return [DescriptionCell cellHeightForObject:self.food forCellWidth:self.view.frame.size.width];
		}
			break;
			case SEPERATOR:
		{
			return self.seperator.frame.size.height;
		}
			break;
		case FOOD_COMMENT:
		{

			NSArray * keyArray = [FoodCommentMananger keyArrayForList:[self.foodID stringValue]];
			NSString *commentID = [keyArray objectAtIndex:indexPath.row];
			NSDictionary *comment = [FoodCommentMananger getObject:commentID inList:[self.foodID stringValue]];
			return [CommentCell cellHeightForComment:comment forCellWidth:self.view.frame.size.width];
	
		}
			break;
		case FOOD_MORE:
			return 40.0;
		case FOOD_TAG:
			return [FoodTagCell cellHeightForObject:self.food forCellWidth:self.view.frame.size.width];
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

#pragma mark - FoodInfoDelegate

- (void) showVC:(UIViewController *)VC
{
	[self.delegate showVC:VC];
}

#pragma mark - GUI

- (void) reloadCommentSection
{
	NSUInteger commentCount = [[FoodCommentMananger keyArrayForList:[self.foodID stringValue]] count];
	static NSMutableIndexSet *commentSectionSet = nil;
	
	if (nil == commentSectionSet)
	{
		commentSectionSet = [[NSMutableIndexSet alloc] init];
		[commentSectionSet addIndex:FOOD_COMMENT];
		[commentSectionSet addIndex:FOOD_MORE];
		[commentSectionSet addIndex:SEPERATOR];
	}
	
	if (self.lastRowCount != commentCount) 
	{
		[self.tableView reloadSections:commentSectionSet withRowAnimation:UITableViewRowAnimationNone];
	}
	
	[self.refreshHeader egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
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

		self.delegate.navigationItem.titleView = self.titleView.view;
		
		self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		self.view.backgroundColor = [Color lightyellow];
		
		if (nil == self.foodInfo)
		{
			self.foodInfo = [[[FoodInfo alloc] init] autorelease];
			self.foodInfo.delegate = self;
		}
		
		if (nil == self.seperator)
		{
			self.seperator = [Seperator createFromXIB];
		}
	}
}

- (void) reload
{
	self.titleView.object = self.food;
	
	[self.tableView reloadData];
}

#pragma mark - object manange

- (void) setFoodID:(NSNumber *)foodID
{
	if (CHECK_EQUAL(foodID, _foodID))
	{
		return;
	}
	
	[_foodID release];
	_foodID = [foodID retain];
	
	self.food = nil;
}

- (void) forceRequestFood
{
	[FoodManager requestObjectWithNumberID:self.foodID
				    andHandler:@selector(refreshFood) 
				     andTarget:self];
}

- (void) requestFood
{	
	if (nil != self.foodID)
	{
		NSDictionary *food = [FoodManager getObjectWithNumberID:self.foodID];
		
		if (nil != food)
		{
			self.food = food;
			self.delegate.toolbar.food = food;
			
			[self reload];
		}
		else 
		{
			[self forceRequestFood];
		}
	
	}
}

- (void) requestNewestComment
{
	[FoodCommentMananger requestNewestWithListID:[self.foodID stringValue] 
					    andCount:COMMENT_REFRESH_WINDOW 
					 withHandler:@selector(reloadCommentSection) 
					   andTarget:self];
}

- (void) requestNewerComment
{	
	[FoodCommentMananger requestNewerWithListID:[self.foodID stringValue] 
					   andCount:COMMENT_REFRESH_WINDOW 
					withHandler:@selector(reloadCommentSection) 
					  andTarget:self];
}

- (void) requestOlderComment
{
	[FoodCommentMananger requestOlderWithListID:[self.foodID stringValue] 
					   andCount:COMMENT_REFRESH_WINDOW 
					withHandler:@selector(reloadCommentSection) 
					  andTarget:self];
}

- (void) pullToRefreshRequest
{
	[self forceRequestFood];
	[self requestNewestComment];
}

- (void) viewWillAppearRequest
{
	[self requestFood];
	[self requestNewerComment];
}

- (void) requestOlder
{
	[self requestOlderComment];
}

- (BOOL) isUpdating
{
	
	return [FoodCommentMananger isUpdatingWithType:REQUEST_NEWEST 
					    withListID:[self.foodID stringValue]];
}
- (NSDate* ) lastUpdateDate
{
	return [FoodCommentMananger lastUpdatedDateForList:[self.foodID stringValue]];
}

- (NSInteger) getCellCountFor:(NSUInteger)section
{
	switch (section)
	{
		case FOOD_DESC:
		{
			if (0 < [[self.food valueForKey:@"desc"] length])
			{
				return 1;
			}
			else 
			{
				return 0;
			}
		}
			break;
			
			
		case FOOD_COMMENT:
		{
			NSUInteger commentCount = [[FoodCommentMananger keyArrayForList:[self.foodID stringValue]] count];
			
			self.lastRowCount = commentCount;
			
			return commentCount;
		}
			break;
			
		case FOOD_TAG:
			if (1 < [[self.food valueForKey:@"tags"] count])
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

@end
