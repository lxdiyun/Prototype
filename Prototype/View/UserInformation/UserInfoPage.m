//
//  UserInfoPage.m
//  Prototype
//
//  Created by Adrian Lee on 12/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "UserInfoPage.h"

#import "Util.h"
#import "ImageV.h"
#import "AvatorCell.h"

UIImage *scaleAndRotateImage(UIImage *image);
@interface UIImage (Extras) 
- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize;
@end


@interface  UserInfoPage   ()
{
@private
	NSArray *_userInfoArray;
	UITextView *_introduceView;
	BOOL _cellChanged;
	NSDictionary *_avatorDict;
}

@property (retain) NSArray *userInfoArray;
@property (retain) UITextView *introduceView;
@property (assign) BOOL cellChanged;
@property (retain) NSDictionary *avatorDict;

- (void)initViewDisplay;
- (void)initUserInfo;
- (void)sendUserInfoRequest;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)handleMessage:(id)dict;
- (void)refreshTableView;
@end

@implementation UserInfoPage

@synthesize userInfoArray = _userInfoArray;
@synthesize introduceView = _introduceView;
@synthesize cellChanged = _cellChanged;
@synthesize avatorDict = _avatorDict;

- (id)initWithStyle:(UITableViewStyle)style
{
	self = [super initWithStyle:UITableViewStyleGrouped];
	if (nil != self) 
	{
	}
	return self;
}

- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)dealloc
{
	LOG(@"%@:%s:%d start", [self class], (char *)_cmd, __LINE__);
	
	[_userInfoArray release];
	[_introduceView release];
	[_avatorDict release];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];

	[self initViewDisplay];

	[self initUserInfo];

	
	[self sendUserInfoRequest];

	
	self.cellChanged = YES;

	// Uncomment the following line to preserve selection between presentations.
	// self.clearsSelectionOnViewWillAppear = NO;
	
	// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
	// self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)initViewDisplay
{
	[self setTitle:@"个人设置"];
	
}

- (void)initUserInfo
{
	@autoreleasepool {
		self.userInfoArray = [NSArray arrayWithObjects:
				      [NSArray arrayWithObjects:@"个人信息", @"姓名：", @"所在地：", nil],
				      [NSArray arrayWithObjects:@"头像", @"头像", nil],
				      [NSArray arrayWithObjects:@"个人介绍", @"", nil],
				      nil];
	}
}

- (void)sendUserInfoRequest
{	
	@autoreleasepool 
	{
		NSMutableDictionary *params =  [[[NSMutableDictionary alloc] init] autorelease];
		NSMutableDictionary *request =  [[[NSMutableDictionary alloc] init] autorelease];
		
		// TODO update to real username
		[params setValue:@"wuvist" forKey:@"username"];
		[params setValue:@"dc6670b66d02cb02990e65272a936f36d25598d4" forKey:@"pwd"];
		
		[request setValue:@"sys.login" forKey:@"method"];
		[request setValue:params forKey:@"params"];
		
		SEND_MSG_AND_BIND_HANDLER(request, self, @selector(handleMessage:));
	}
}

- (void)viewDidUnload
{
	LOG(@"%@:%s:%d start", [self class], (char *)_cmd, __LINE__);
	
	[super viewDidUnload];
	// Release any retained subviews of the main view.
	[self setUserInfoArray:nil];
	[self setIntroduceView:nil];
	[self setAvatorDict:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return self.userInfoArray.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	// first element is for sectoin title
	// hide for first two section user name city and avator
	if((section == 0) || (section == 1)) 
	{
		return nil;
	}
	
	return [[self.userInfoArray objectAtIndex:section] objectAtIndex:0];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	// Return the number of rows in the section.
	// decrease one for section title
	return ([[self.userInfoArray objectAtIndex:section] count] - 1);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (1 == indexPath.section)
	{
		static NSString *cellType = @"AvatorCell";
		
		AvatorCell *cell = [tableView dequeueReusableCellWithIdentifier:cellType];
		if (cell == nil) 
		{
			cell = [[[AvatorCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellType] autorelease];
			cell.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, 44);
			[cell redraw];
		}

		if (nil != self.avatorDict)
		{
			cell.avatorImageV.picDict = self.avatorDict;
		}
		
		return cell;
	}
	
	NSString *CellIdentifier = [[self.userInfoArray objectAtIndex:indexPath.section] objectAtIndex:0];
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil) 
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		if (2 == indexPath.section)
		{
			UITextView *textView = [[UITextView alloc] initWithFrame:CGRectZero];
			self.introduceView = textView;

			[cell.contentView addSubview:self.introduceView];
			
			[textView release];
		}
	}

	// Configure the cell...

	if (YES == self.cellChanged)
	{
		[self configureCell:cell atIndexPath:indexPath];
	}
	
	return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
	switch (indexPath.section)
	{
			
	case 2:
		{
			cell.textLabel.enabled =  NO;
			cell.textLabel.hidden = YES;
			
			self.cellChanged = NO;
		}
			break;
	default:
			cell.textLabel.text = [[self.userInfoArray objectAtIndex:
						indexPath.section] 
					       objectAtIndex:(indexPath.row + 1)];
			break;
	}

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  
{ 
	switch (indexPath.section)
	{
	case 1:
			return 44;
			break;
	case 2:
		{
			NSString *string = [[self.userInfoArray objectAtIndex:indexPath.section]
					    objectAtIndex:1];
			
			CGRect rect = CGRectMake(0, 
						 0, 
						 self.introduceView.superview.frame.size.width, 
						 self.introduceView.superview.frame.size.height);
			
			// configure text view display
			self.introduceView.frame = rect;
			self.introduceView.font = [UIFont boldSystemFontOfSize:17.0];
			self.introduceView.userInteractionEnabled = NO;
			self.introduceView.editable = NO;
			self.introduceView.scrollEnabled = NO;
			self.introduceView.backgroundColor = [UIColor clearColor];
			self.introduceView.text = string;
			
			CGRect frame = self.introduceView.frame;
			frame.size.height = self.introduceView.contentSize.height;
			self.introduceView.frame = frame;
			
			return MAX(self.introduceView.frame.size.height, 44);
			break;
		}
		
	default:
			return 44;
	}
	
	

}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
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

// did not provide selectable cell
-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	return Nil;
}

- (void)handleMessage:(id)dict
{

	if (![dict isKindOfClass: [NSDictionary class]])
	{
		LOG(@"Error handle non dict object");
		return;
	}
	
	NSDictionary *messageDict = (NSDictionary*)dict;
	
	NSString *userName = [NSString stringWithFormat:@"姓名：%@", [[messageDict objectForKey:@"result"] objectForKey:@"nick"]];
	NSString *city = [NSString stringWithFormat:@"所在地：%@", [[messageDict objectForKey:@"result"] objectForKey:@"city"]];
	
	NSString *introduceString = [[messageDict objectForKey:@"result"] objectForKey:@"intro"];
	
	self.userInfoArray = [NSArray arrayWithObjects:
			      [NSArray arrayWithObjects:@"个人信息", userName, city, nil],
			      [NSArray arrayWithObjects:@"头像", @"头像", nil],
			      [NSArray arrayWithObjects:@"个人介绍", introduceString, nil],
			      nil];
	
	self.avatorDict = [[messageDict objectForKey:@"result"] objectForKey:@"avatar"];
	
	self.cellChanged = YES;
	
	[self refreshTableView];
}

- (void)refreshTableView
{
	LOG(@"%@:%s:%d start", [self class], (char *)_cmd, __LINE__);

	if (YES == [self.view isKindOfClass:[UITableView class]])
	{
		[(UITableView *)self.view reloadData];
	}
}

@end

