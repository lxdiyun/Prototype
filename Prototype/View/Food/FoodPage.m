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

const static uint32_t COMMENT_REFRESH_WINDOW = 5;
const static CGFloat IMAGE_SIZE = 320.0;
const static CGFloat FONT_SIZE = 15.0;

typedef enum FOOD_PAGE_SECTION_ENUM
{
	FOOD_INFO = 0x0,
	FOOD_DESC = 0x1,
	FOOD_COMMENT = 0x2,
	FOOD_MORE = 0x3,
	FOOD_TAG = 0x4,
	FOOD_SECTION_MAX
} FOOD_PAGE_SECTION;

@interface FoodPage () <UIScrollViewDelegate, TextInputerDeletgate>
{
	NSDictionary *_foodObject;
	NSString *_foodID;
	TextInputer *_inputer;
	UINavigationController *_navco;
	TitleVC *_titleView;
	FoodInfo *_foodInfo;
}

@property (strong) NSString *foodID;
@property (strong, nonatomic) TextInputer *inputer;
@property (strong, nonatomic) UINavigationController *navco;
@property (strong, nonatomic) TitleVC *titleView;
@property (strong, nonatomic) FoodInfo *foodInfo;
@end

@implementation FoodPage

@synthesize foodObject = _foodObject;
@synthesize foodID = _foodID;
@synthesize inputer = _inputer;
@synthesize navco = _navco;
@synthesize titleView = _titleView;
@synthesize foodInfo = _foodInfo;

#pragma mark - util

static int32_t s_lastCommentArrayCount = -1;

- (void) refreshCommentSection
{
	int32_t commentArrayCount = [[FoodCommentMananger keyArrayForList:self.foodID] count];
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
	int32_t commentArrayCount = [[FoodCommentMananger keyArrayForList:self.foodID] count];
	
	[self.tableView reloadData];
	
	s_lastCommentArrayCount = commentArrayCount;
}

#pragma mark message

- (void) requestNewerComment
{	
	[FoodCommentMananger requestNewerWithListID:self.foodID 
					   andCount:COMMENT_REFRESH_WINDOW 
					withHandler:@selector(refreshCommentSection) 
					  andTarget:self];
}

- (void) requestOlderComment
{
	[FoodCommentMananger requestOlderWithListID:self.foodID 
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
	self.foodObject = nil;
	self.foodID = nil;
	self.inputer = nil;
	self.navco = nil;
	self.titleView = nil;
	self.foodInfo = nil;
	
	[super dealloc];
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
		self.navigationItem.leftBarButtonItem = SETUP_BACK_BAR_BUTTON(self, 
									      @selector(backToPrevView));
		
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
	
	self.foodObject = nil;
	self.foodID = nil;
	self.inputer = nil;
	self.navco = nil;
	self.titleView = nil;
	self.foodInfo = nil;
}

- (void) viewWillAppear:(BOOL)animated
{	
	self.titleView.name.text = [self.foodObject valueForKey:@"name"];
	self.titleView.placeName.text = [NSString stringWithFormat:@"@%@", 
					 [self.foodObject valueForKey:@"place_name"]];
	self.foodID = [[self.foodObject valueForKey:@"id"] stringValue];
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
		{
			NSUInteger commentCount = [[FoodCommentMananger keyArrayForList:self.foodID] count];

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
			NSInteger loadedComment =  [[FoodCommentMananger keyArrayForList:self.foodID] count];
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

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch (indexPath.section) 
	{
		case FOOD_INFO:
		{
			static NSString *userCellIndentifier = @"FoodUserCell";
			
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:userCellIndentifier];
			
			if (nil == self.foodInfo)
			{
				self.foodInfo = [[[FoodInfo alloc] init] autorelease];
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
			break;
		case FOOD_DESC:
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
			break;

		case FOOD_COMMENT:
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
				}
				
				NSArray * keyArray = [FoodCommentMananger keyArrayForList:self.foodID];
				NSString *commentID = [keyArray objectAtIndex:indexPath.row - 1];
				cell.commentDict = [FoodCommentMananger getObject:commentID inList:self.foodID];
				
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
						 backColor:[UIColor whiteColor] 
						 triangleColor:[Color orangeColor]
						 ] autorelease];
				}
				
				return cell;
			}
		}
			break;
		case FOOD_MORE:
		{
			static NSString *moreCellIdentifier = @"moreCommentCell";
			
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:moreCellIdentifier];
			
			if (nil == cell)
			{
				cell = [[[UITableViewCell  alloc] initWithStyle:UITableViewCellStyleDefault 
								reuseIdentifier:moreCellIdentifier] autorelease];
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				
				CGRect buttonFrame = CGRectMake(0, 0, self.view.frame.size.width, 44.0);
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
			break;
		case FOOD_TAG:
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
				NSArray * keyArray = [FoodCommentMananger keyArrayForList:self.foodID];
				NSString *commentID = [keyArray objectAtIndex:indexPath.row - 1];
				NSDictionary *comment = [FoodCommentMananger getObject:commentID inList:self.foodID];
				return [CommentCell cellHeightForComment:comment forCellWidth:self.view.frame.size.width];
			}
			else 
			{
				return 10.0;
			}
		}
			break;
		case FOOD_TAG:
			return 40.0;
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
