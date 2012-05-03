//
//  titleVC.m
//  Prototype
//
//  Created by Adrian Lee on 5/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TitleVC.h"

#import "Util.h"

@interface TitleVC ()

@end

@implementation TitleVC
@synthesize name;
@synthesize placeName;

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) 
	{
	}
	return self;
}

- (void) viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view from its nib.
}

- (void) viewDidUnload
{
	[self setName:nil];
	[self setPlaceName:nil];
	[super viewDidUnload];
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc 
{
	[name release];
	[placeName release];
	[super dealloc];
}
@end
