//
//  MapViewPage.m
//  Prototype
//
//  Created by Adrian Lee on 3/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MapViewPage.h"

#import <MapKit/MapKit.h>

#import "MKMapView+ZoomLevel.h"
#import "Util.h"
#import "FoodMapListManager.h"
#import "PlaceManager.h"
#import "MapAnnotation.h"


@interface MapViewPage () <MKMapViewDelegate>
{
	MKMapView *_mapView;
	BOOL _focousUser;
	NSDictionary *_mapObject;
	NSArray *_unAddedPlacesIDArray;
}

@property (strong) MKMapView *mapView;
@property (assign) BOOL focousUser;
@property (strong) NSArray *unAddedPlacesIDArray;

@end

@implementation MapViewPage

@synthesize mapView = _mapView;
@synthesize focousUser = _focousUser;
@synthesize mapObject = _mapObject;
@synthesize unAddedPlacesIDArray = _unAddedPlacesIDArray;

#pragma mark - map location and annotations

- (void) goToLastCenter
{
	CLLocationCoordinate2D center;
	NSUInteger zoomLevel;
	
	center.latitude = [[self.mapObject valueForKey:@"lat"] doubleValue];
	center.longitude = [[self.mapObject valueForKey:@"lng"] doubleValue];
	zoomLevel = [[self.mapObject valueForKey:@"zoom"] unsignedIntegerValue];

	[self.mapView setCenterCoordinate:center zoomLevel:zoomLevel animated:YES];
	
}

- (void) saveMapObject
{
	@autoreleasepool 
	{
		NSMutableDictionary *newFoodMap = [[self.mapObject mutableCopy] autorelease]; 
		CLLocationCoordinate2D center = self.mapView.centerCoordinate;
		NSUInteger zoomLevel = self.mapView.zoomLevel;
		
		[newFoodMap setValue:[NSNumber numberWithDouble:center.latitude] forKey:@"lat"];
		[newFoodMap setValue:[NSNumber numberWithDouble:center.longitude] forKey:@"lng"];
		[newFoodMap setValue:[NSNumber numberWithUnsignedInteger: zoomLevel] forKey:@"zoom"];
		
		for (NSString *key in newFoodMap.allKeys)
		{
			if ([key isEqualToString:@"id"])
			{
				continue;
			}
			else if ([self.mapObject valueForKey:key] == [newFoodMap valueForKey:key]) 
			{
				[newFoodMap setValue:nil forKey:key];
			}
		}
		
		if (1 < newFoodMap.count)
		{
			[FoodMapListManager updateFoodMap:newFoodMap withHandler:nil andTarget:nil];
		}
	}	
}

- (void) reloadMapObject
{
	@autoreleasepool 
	{
		NSString *mapID = [[self.mapObject valueForKey:@"id"] stringValue];
		NSString *loginUserID = [GET_USER_ID() stringValue];
		
		if (nil != loginUserID && nil != mapID)
		{
			[FoodMapListManager requestMiddle:mapID 
						 inListID:loginUserID 
						 andCount:1 
					      withHandler:@selector(updatePlaces) 
						andTarget:self];
		}
		
		
	}
}

- (void) addPlaces
{
	@autoreleasepool 
	{
		NSMutableArray *unknowPlacesIDArray = [[[NSMutableArray alloc] init] autorelease];
		NSMutableArray *placeAnnotationArray = [[[NSMutableArray alloc] init] autorelease];
		
		for (NSNumber *placeID in self.unAddedPlacesIDArray) 
		{
			NSDictionary *placeObject = [PlaceManager getObjectWithNumberID:placeID];
			MapAnnotation *placeAnnotation;
			
			if (nil == placeObject)
			{

				[unknowPlacesIDArray addObject:placeID];
				continue;
			}
			
			placeAnnotation = [[[MapAnnotation alloc] init] autorelease];
			placeAnnotation.placeObject = placeObject;
			
			[placeAnnotationArray addObject:placeAnnotation];
		}
		
		
		[self.mapView addAnnotations:placeAnnotationArray];
		
		if (0 < unknowPlacesIDArray.count)
		{
			self.unAddedPlacesIDArray = unknowPlacesIDArray;
			[PlaceManager requestObjectWithNumberIDArray:unknowPlacesIDArray];
			[PlaceManager requestObjectWithNumberID:[unknowPlacesIDArray objectAtIndex:0] 
						     andHandler:@selector(addPlaces) 
						      andTarget:self];
		}
		else 
		{
			self.unAddedPlacesIDArray = nil;
		}
	}
}

- (void) updatePlaces
{
	NSString *mapID = [[self.mapObject valueForKey:@"id"] stringValue];
	NSString *loginUserID  = [GET_USER_ID() stringValue];

	[self.mapView removeAnnotations:self.mapView.annotations];
	
	self.mapObject = [FoodMapListManager getObject:mapID inList:loginUserID];
	
	if (nil != self.mapView)
	{
		self.unAddedPlacesIDArray = [self.mapObject valueForKey:@"places"];
		[PlaceManager requestObjectWithNumberIDArray:self.unAddedPlacesIDArray];
		
		[self addPlaces];
	}
}

- (void) showAllPlaces
{
	if([self.mapView.annotations count] == 0)
		return;
	
	CLLocationCoordinate2D topLeftCoord;
	topLeftCoord.latitude = -90;
	topLeftCoord.longitude = 180;
	
	CLLocationCoordinate2D bottomRightCoord;
	bottomRightCoord.latitude = 90;
	bottomRightCoord.longitude = -180;

	for (MKPlacemark *annotation in self.mapView.annotations)
	{
		topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
		topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);
		
		bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude);
		bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);
	}
	
	MKCoordinateRegion region;
	region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
	region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
	region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.1; // Add a little extra space on the sides
	region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.1; // Add a little extra space on the sides
	
	region = [self.mapView regionThatFits:region];
	[self.mapView setRegion:region animated:YES];
}
- (void) updateUserLocation:(MKUserLocation *) userLocation
{
	CLLocationAccuracy accuracy = userLocation.location.horizontalAccuracy;
	
	if (accuracy > 0 ) 
	{
		if(nil != userLocation)
		{
			CLLocationDegrees spanInDegrees = (CLLocationDegrees) (accuracy / 222240);
			MKCoordinateSpan span = MKCoordinateSpanMake(spanInDegrees, spanInDegrees);
			MKCoordinateRegion region = MKCoordinateRegionMake(userLocation.location.coordinate, span);
			
			[self.mapView setRegion:region animated:YES];
		}
		else 
		{
			[self performSelector:@selector(userLocation) withObject:nil afterDelay:1.0];
		}
	}
}

- (void) focousUserLoaction
{
	self.focousUser = YES;
	self.mapView.showsUserLocation = YES;

	[self updateUserLocation:self.mapView.userLocation];
}

#pragma mark - life circle

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

	if (self) 
	{
		@autoreleasepool 
		{
			self.mapView = [[[MKMapView alloc] init] autorelease];
			self.view = self.mapView;
			self.mapView.delegate = self;
			UIBarButtonItem *refresh = [[[UIBarButtonItem alloc] 
							   initWithTitle:@"刷新" 
							   style:UIBarButtonItemStylePlain 
							   target:self
							   action:@selector(reloadMapObject)] 
							  autorelease];
			UIBarButtonItem *showAllPlaces = [[[UIBarButtonItem alloc] 
							   initWithTitle:@"所有地点" 
							   style:UIBarButtonItemStylePlain 
							   target:self
							   action:@selector(showAllPlaces)] 
							  autorelease];
			
			UIBarButtonItem *showWhereAmI = [[[UIBarButtonItem alloc] 
							  initWithTitle:@"我在哪？"
							  style:UIBarButtonItemStylePlain 
							  target:self
							  action:@selector(focousUserLoaction)]
							 autorelease];

			self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:refresh, showWhereAmI,showAllPlaces, nil];
		}
	}
	
	return self;
}

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	self.focousUser = NO;
	self.mapView.showsUserLocation = NO;
}

- (void) viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	[self saveMapObject];
}

- (void) viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[self goToLastCenter];
	
	[self updatePlaces];
}

- (void) viewDidLoad
{
	[super viewDidLoad];
}

- (void) viewDidUnload
{
	self.mapView = nil;
	self.mapObject = nil;
	self.unAddedPlacesIDArray = nil;

	[super viewDidUnload];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - MKMapViewDelegate

- (void) mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation      
{
	if (self.focousUser)
	{
		[self updateUserLocation:userLocation];
		
		self.focousUser = NO;
	}
}

- (void) showInSystemMap
{
	
	@autoreleasepool 
	{
		MapAnnotation *selectedAnnotation = [self.mapView.selectedAnnotations objectAtIndex:0];
		
		if ([selectedAnnotation isKindOfClass:[MapAnnotation class]])
		{
			CLLocationCoordinate2D coordinate = selectedAnnotation.coordinate;
			NSString *latlong = [NSString stringWithFormat:@"%lf,%lf", coordinate.latitude, coordinate.longitude];
			NSString *title  = [selectedAnnotation.placeObject valueForKey:@"address"];
			NSString *url = [NSString stringWithFormat: @"http://maps.google.com/maps?q=%@&ll=%@",
					 [title stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
					 [latlong stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
			
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
		}
	}
	
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
	// if it's the user location, just return nil.
	if ([annotation isKindOfClass:[MKUserLocation class]])
		return nil;
	
	// try to dequeue an existing pin view first
        static NSString* pinViewIdentifier = @"pinView";
        MKPinAnnotationView* pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:pinViewIdentifier];
	
        if (nil == pinView)
        {
		// if an existing pin view was not available, create one
		pinView = [[[MKPinAnnotationView alloc]
						       initWithAnnotation:annotation reuseIdentifier:pinViewIdentifier] autorelease];
		pinView.pinColor = MKPinAnnotationColorGreen;
		pinView.animatesDrop = YES;
		pinView.canShowCallout = YES;
		
		UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
		[rightButton addTarget:self
				action:@selector(showInSystemMap)
		      forControlEvents:UIControlEventTouchUpInside];
		pinView.rightCalloutAccessoryView = rightButton;
	}

	pinView.annotation = annotation;
	
	return pinView;
}

@end
