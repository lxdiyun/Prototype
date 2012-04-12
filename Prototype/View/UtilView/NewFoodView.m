//
//  NewFoodView.m
//  Prototype
//
//  Created by Adrian Lee on 1/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NewFoodView.h"

#import "TextFieldCell.h"
#import "Util.h"

typedef enum NEW_FOOD_SECTION_ENUM
{
	FOOD_DETAIL = 0x0,
	FOOD_DESC = 0x1,
	NEW_FOOD_SECTION_MAX
} NEW_FOOD_SECTION;

typedef enum NEW_FOOD_DETAIL_ENUM
{
	FOOD_NAME = 0x0,
	FOOD_CITY = 0x1,
	FOOD_TAG = 0x2,
	NEW_FOOD_DETAIL_MAX
} NEW_FOOD_DETAIL;

static NSString *FOOD_DETAIL_TITLE[NEW_FOOD_DETAIL_MAX] = {@"名字：", @"所在地：", @"类型"};

@implementation NewFoodView

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
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

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
		default:
			return 1;
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

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch (indexPath.section) {
		case FOOD_DESC:
			return 88 * PROPORTION();
			break;
			
		default:
			return 44 * PROPORTION();
			break;
	}
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch (indexPath.section) 
	{
		case FOOD_DETAIL:
		{
			static NSString *cellType = @"FoodDetail";
			
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellType];
			
			if (cell == nil) 
			{
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2
							      reuseIdentifier:cellType];
				[cell release];
			}
			
			cell.textLabel.text = FOOD_DETAIL_TITLE[indexPath.row];
			
			return cell;
			
		}
			break;
		case FOOD_DESC:
		{
			static NSString *cellType = @"FoodDescription";
			
			TextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:cellType];
			
			if (cell == nil) 
			{
				cell = [[TextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault
							    reuseIdentifier:cellType];
				cell.frame = CGRectMake(0.0, 
							0.0, 
							self.view.frame.size.width,  
							88 * PROPORTION());
				[cell release];
			}
			
			cell.textLabel.text = FOOD_DETAIL_TITLE[indexPath.row];
			
			return cell;
		}
			break;
		default:
			return nil;
			break;
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

@end
