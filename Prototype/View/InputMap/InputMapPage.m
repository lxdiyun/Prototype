//
//  InputMapPage.m
//  Prototype
//
//  Created by Adrian Lee on 5/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InputMapPage.h"

#import "Util.h"

@interface InputMapPage ()
{
	MapAnnotation *_annotation;
}

@end

@implementation InputMapPage
@synthesize annotation = _annotation;
@synthesize map;


#pragma mark - life circle

- (id) initWithNibName:(NSString *)nibNameOrNil 
		bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

	if (self) 
	{
		self.annotation = [[[MapAnnotation alloc] init] autorelease];
	}

	return self;
}

- (void) dealloc 
{
	self.annotation = nil;

	[map release];
	[super dealloc];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	
	HANDLE_MEMORY_WARNING(self);
}

#pragma mark - view life circle

- (void) viewDidLoad
{
	[super viewDidLoad];
}

- (void) viewDidUnload
{
	self.annotation = nil;
	
	[self setMap:nil];
	[super viewDidUnload];
}

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self.map removeAnnotation:self.annotation];
	[self.map addAnnotation:self.annotation];
}



@end
