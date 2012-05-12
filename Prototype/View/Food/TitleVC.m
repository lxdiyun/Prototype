//
//  titleVC.m
//  Prototype
//
//  Created by Adrian Lee on 5/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TitleVC.h"

#import "Util.h"
#import "PlaceManager.h"

@interface TitleVC ()
{
	NSDictionary *_object;
}

@end

@implementation TitleVC
@synthesize name;
@synthesize placeName;
@synthesize object = _object;

#pragma mark - life circle

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
	
	[self updateGUI];
}

- (void) viewDidUnload
{
	self.object = nil;
	[self setName:nil];
	[self setPlaceName:nil];

	[super viewDidUnload];
}

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) dealloc 
{
	self.object = nil;
	
	[name release];
	[placeName release];
	
	[super dealloc];
}

#pragma mark - update object

- (void) updatePlace
{
	@autoreleasepool 
	{
		NSNumber *placeID = [self.object valueForKey:@"place"];
		
		if (nil != placeID) 
		{
			NSDictionary *place = [PlaceManager getObjectWithNumberID:placeID];
			
			if (nil != place) 
			{
				self.placeName.text = [NSString stringWithFormat:@"@%@", [place valueForKey:@"name"]];
			}
			else 
			{
				[PlaceManager requestObjectWithNumberID:placeID andHandler:@selector(updatePlace) andTarget:self];
			}
		}

	}
}

- (void) updateGUI	
{
	self.name.text = [self.object valueForKey:@"name"];
	
	[self updatePlace];
}

- (void) setObject:(NSDictionary *)object
{
	if ([_object isEqualToDictionary:object])
	{
		return;
	}
	
	[_object release];
	_object = [object retain];

	[self updateGUI];
}

@end
