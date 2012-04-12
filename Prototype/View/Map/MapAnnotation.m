//
//  MapAnnotation.m
//  Prototype
//
//  Created by Adrian Lee on 3/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MapAnnotation.h"

@interface MapAnnotation ()
{
	NSDictionary *_placeObject;
	CLLocationCoordinate2D _coordinate;
	NSString *_title;
	
}
@end

@implementation MapAnnotation

@synthesize coordinate = _coordinate;
@synthesize placeObject = _placeObject;
@synthesize title = _title;

- (void) dealloc
{
	[_title release];
	_title = nil;
	self.placeObject = nil;
	
	[super dealloc];
}

- (void) setPlaceObject:(NSDictionary *)newPlaceObject
{
	if (_placeObject == newPlaceObject)
	{
		return;
	}
	
	[_placeObject release];
	
	_placeObject = [newPlaceObject retain];
	
	_coordinate.latitude = [[self.placeObject valueForKey:@"lat"] doubleValue];
	_coordinate.longitude =  [[self.placeObject valueForKey:@"lng"] doubleValue]; 
	
	[_title release];
	_title = [[self.placeObject valueForKey:@"name"] retain];
}

@end
