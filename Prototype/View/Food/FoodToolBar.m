//
//  FoodToolBar.m
//  Prototype
//
//  Created by Adrian Lee on 6/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FoodToolBar.h"

#import "MapViewPage.h"
#import "FoodManager.h"
#import "TextInputer.h"
#import "FoodCommentMananger.h"

@interface FoodToolBar () <UIAlertViewDelegate, TextInputerDeletgate>
{
	TextInputer *_inputer;
	UINavigationController *_inputNavco;
	NSDictionary *_food;
	id<FoodToolBarDelegate> _delegate;
	MapViewPage *_map;
	UIAlertView *_deleteAlert;
}

@property (strong, nonatomic) MapViewPage *map;
@property (strong, nonatomic) UIAlertView *deleteAlert;
@property (strong, nonatomic) TextInputer *inputer;
@property (strong, nonatomic) UINavigationController *inputNavco;

@end

@implementation FoodToolBar

@synthesize food = _food;
@synthesize deleteButton;
@synthesize locationButton;
@synthesize delegate = _delegate;
@synthesize map = _map;
@synthesize deleteAlert = _deleteAlert;
@synthesize inputer = _inputer;
@synthesize inputNavco = _inputNavco;

#pragma mark - custom xib object

// 1 is for default bar item
DEFINE_CUSTOM_XIB(FoodToolBar, 1);

- (void) resetupXIB:(FoodToolBar *)xibInstance
{
	[xibInstance initGUI];

	xibInstance.delegate = self.delegate;
	xibInstance.frame = self.frame;
}

#pragma mark - life circle

- (void) dealloc
{
	self.map = nil;
	self.deleteAlert = nil;
	self.food = nil;
	self.inputer = nil;
	self.inputNavco = nil;

	[deleteButton release];
	[locationButton release];
	[super dealloc];
}

#pragma mark - GUI

- (void) initGUI
{
	CONFIG_TOOL_BAR(self);

	if (nil == self.map)
	{
		MapViewPage *map = [[MapViewPage alloc] init];
		self.map = map;
		
		[map release];
	}
	
	if (nil == self.deleteAlert)
	{
		UIAlertView *deleteAlert = [[UIAlertView alloc] initWithTitle:@"删除?" 
								      message:@"" 
								     delegate:self 
							    cancelButtonTitle:@"取消" 
							    otherButtonTitles:nil];
		[deleteAlert addButtonWithTitle:@"确认"];
		
		self.deleteAlert = deleteAlert;
		
		[deleteAlert release];
	}
	
	if (nil == self.inputer)
	{
		self.inputer = [[[TextInputer alloc] init] autorelease];
		self.inputer.delegate = self;
		self.inputer.title = @"添加评论";
	}
	
	if (nil == self.inputNavco)
	{
		self.inputNavco = [[[UINavigationController alloc] initWithRootViewController:
			       self.inputer] autorelease];
		CONFIG_NAGIVATION_BAR(self.inputNavco.navigationBar);
	}
}

- (void) updateButtons
{
	if (CHECK_EQUAL([self.food valueForKey:@"user"], GET_USER_ID()))
	{
		
		self.deleteButton.enabled = YES;
	}
	else 
	{
		self.deleteButton.enabled = NO;
	}

	if (nil != [self.food valueForKey:@"place"])
	{
		self.locationButton.enabled = YES;
	}
	else 
	{
		self.locationButton.enabled = NO;
	}
}

#pragma mark - action

- (void) foodDeleted
{
	[self.delegate foodDeleted:self];
}

- (void) createCommentHandler:(id)result
{
	[self.delegate comentCreated:result];
}

- (IBAction) showLocation:(id)sender 
{	
	NSMutableDictionary *tempMap = [[NSMutableDictionary alloc] init];
	NSArray *placeIDArray = [[NSArray alloc] initWithObjects:[self.food valueForKey:@"place"], nil];
	
	[tempMap setValue:[self.food valueForKey:@"name"] forKey:@"title"];
	[tempMap setValue:placeIDArray forKey:@"places"];
	
	self.map.mapObject = tempMap;
	
	if (0 < placeIDArray.count)
	{
		[self.delegate showVC:self.map];
	}
	
	[placeIDArray release];
	[tempMap release];
}

- (IBAction) addComent:(id)sender 
{
	@autoreleasepool 
	{
		[self.delegate showModalVC:self.inputNavco withAnimation:YES];
	}
}

- (IBAction) deleteFood:(id)sender 
{
	@autoreleasepool 
	{
		self.deleteAlert.title = [NSString stringWithFormat:@"删除 %@？", [self.food valueForKey:@"name"]];
		[self.deleteAlert show];
	}
}

#pragma mark - UIAlertViewDelegate

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if ((alertView == self.deleteAlert) && (1 == buttonIndex))
	{
		[FoodManager deleteObject:[self.food valueForKey:@"id"] withhandler:@selector(foodDeleted) andTarget:self];
	}
}

#pragma mark - textInputerDelegate

- (void) textDoneWithTextInputer:(TextInputer *)inputer
{
	[self.delegate dismissModalVC:self.inputNavco withAnimation:YES];
	[FoodCommentMananger createComment:inputer.text.text 
				   forList:[[self.food valueForKey:@"id"] stringValue] 
			       withHandler:@selector(createCommentHandler:) 
				 andTarget:self];
}

- (void) cancelWithTextInputer:(TextInputer *)inputer
{
	[self.delegate dismissModalVC:self.inputNavco withAnimation:YES];
}

#pragma mark - object Manage

- (void) setFood:(NSDictionary *)food
{
	if (CHECK_EQUAL(_food ,food))
	{
		return;
	}
	
	[_food release];
	
	_food = [food retain];
	
	[self updateButtons];	
}

@end
