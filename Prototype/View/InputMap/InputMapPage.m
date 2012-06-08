//
//  InputMapPage.m
//  Prototype
//
//  Created by Adrian Lee on 5/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InputMapPage.h"

#import "Util.h"
#import "MapAnnotationView.h"

@interface InputMapPage () <MKMapViewDelegate>
{
	MapAnnotation *_annotation;
	id<InputMapDelegate> _delegate;
	BOOL _foucousUser;
	NSString *_placeName;
	NSString *_city;
}

@property (assign, nonatomic) BOOL focousUser;

@end

@implementation InputMapPage

@synthesize annotation = _annotation;
@synthesize focousUser = _foucousUser;
@synthesize city = _city;
@synthesize placeName = _placeName;
@synthesize delegate = _delegate;
@synthesize map;



#pragma mark - life circle

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
	
	[self initGUI];
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
	
	[self updateGUI];
}

#pragma mark - GUI

- (void) initGUI
{
	self.map.delegate = self;	
	CONFIG_NAGIVATION_BAR(self.navigationController.navigationBar);

	// set all buttons
	self.navigationItem.hidesBackButton = YES;
	self.navigationItem.rightBarButtonItem = SETUP_BAR_TEXT_BUTTON(@"完成", self, @selector(placeSeleted));
	self.navigationItem.leftBarButtonItem = SETUP_BACK_BAR_BUTTON(self, @selector(back));
	
	[self initAnnotation];
}

- (void) updateGUI
{
	self.focousUser = NO;
	
	self.title = [NSString stringWithFormat:@"%@在哪里?", self.placeName];
}

- (void) back
{
	self.city = nil;
	self.placeName = nil;
	POP_VC(self.navigationController, YES);
}

#pragma mark - GUI - map

- (void) focousUserLoaction
{
	self.focousUser = YES;
	
	self.map.showsUserLocation = YES;
	
	[self updateUserLocation:self.map.userLocation];
}

- (void) updateUserLocation:(MKUserLocation *)userLocation
{
	CLLocationAccuracy accuracy = userLocation.location.horizontalAccuracy;
	
	if (accuracy > 0 ) 
	{
//		[self updateAnnotation];
		
		MKMapPoint userPoint = MKMapPointForCoordinate(userLocation.location.coordinate);
		MKMapRect currentRect = [self.map visibleMapRect];
		
		if (!MKMapRectContainsPoint(currentRect, userPoint) && self.focousUser)
		{
			[self.map setCenterCoordinate:userLocation.location.coordinate animated:YES];
		}
		
		self.focousUser = NO;
	}
}

- (void) initAnnotation
{
	if (nil == self.annotation)
	{
		MapAnnotation *annotation = [[MapAnnotation alloc] init];
		
		self.annotation = annotation;
		
		[self.map addAnnotation:self.annotation];
		[self updateAnnotation];
		
		[annotation release];
	}
}

- (void) updateAnnotation
{
	if ((nil != self.city) && (nil != self.placeName))
	{
		NSString *address = [[NSString alloc] initWithFormat:@"%@+%@", 
				     self.city, 
				     self.placeName];
		
		self.annotation.coordinate = [self getLocationFromAddressString:address];
		
		[address release];
	}
	
	[self showAllPlaces];
}

- (void) reset
{
	[self updateAnnotation];
}

- (void) showAllPlaces
{	
	[self showPlaces:self.map.annotations];
}

- (void) showPlaces:(NSArray *)annotations
{
	if(0 == [annotations count])
	{
		return;
	}
	
	CLLocationCoordinate2D topLeftCoord;
	topLeftCoord.latitude = -90;
	topLeftCoord.longitude = 180;
	
	CLLocationCoordinate2D bottomRightCoord;
	bottomRightCoord.latitude = 90;
	bottomRightCoord.longitude = -180;
	
	for (MKPlacemark *annotation in annotations)
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
	
	region = [self.map regionThatFits:region];
	[self.map setRegion:region animated:YES];
}

-(CLLocationCoordinate2D) getLocationFromAddressString:(NSString*) addressStr 
{
	NSMutableString *urlStr = [NSMutableString stringWithFormat:@"http://ditu.google.cn/maps/geo?q=%@&output=csv", 
				   [addressStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	
	CLLocationAccuracy accuracy = self.map.userLocation.location.horizontalAccuracy;
	CLLocationCoordinate2D userLocation =  self.map.userLocation.location.coordinate;
	
	if (accuracy > 0 ) 
	{
		[urlStr appendFormat:@"&ll=%f,%f&spn=0.2,0.2", 
		 userLocation.latitude, 
		 userLocation.longitude];
	}
	
	NSError *error = nil;
	NSString *locationStr = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlStr] 
							 encoding:NSUTF8StringEncoding 
							    error:&error];
	NSArray *items = [locationStr componentsSeparatedByString:@","];
	
	double latitude = 0.0;
	double longitude = 0.0;
	
	if([items count] >= 4 && [[items objectAtIndex:0] isEqualToString:@"200"] && (nil == error)) 
	{
		latitude = [[items objectAtIndex:2] doubleValue];
		longitude = [[items objectAtIndex:3] doubleValue];
		
		CLLocationCoordinate2D location;
		location.latitude = latitude;
		location.longitude = longitude;
		
		return location;
	}
	else 
	{
		LOG(@"Address, %@ not found: Error %@ %@", addressStr, [items objectAtIndex:0], error);
		
		return userLocation;
	}
}

#pragma mark - MKMapViewDelegate

- (void) mapView:(MKMapView *)mapView
didUpdateUserLocation:(MKUserLocation *)userLocation  
{
	[self updateUserLocation:userLocation];
}

- (void) mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
	switch([error code])
	{
		case kCLErrorLocationUnknown: // location is currently unknown, but CL will keep trying
			break;
			
		case kCLErrorDenied: // CL access has been denied (eg, user declined location use)
		{
			// update annonation without user location
			[self initAnnotation];
		}
			break;
			
		case kCLErrorNetwork: // general, network-related error
			break;
	}
}

- (void) mapView:(MKMapView *)mapView 
  annotationView:(MKAnnotationView *)annotationView 
didChangeDragState:(MKAnnotationViewDragState)newState 
    fromOldState:(MKAnnotationViewDragState)oldState
{
}

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
	// if it's the user location, just return nil.
	if ([annotation isKindOfClass:[MKUserLocation class]])
		return nil;
	
	// try to dequeue an existing pin view first
	static NSString* annotationViewIdentifier = @"MapAnnotationView";
	MKPinAnnotationView* annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationViewIdentifier];
	
	if (nil == annotationView)
	{
		// if an existing pin view was not available, create one
		annotationView = [[[MKPinAnnotationView alloc]
				   initWithAnnotation:annotation 
				   reuseIdentifier:annotationViewIdentifier] 
				  autorelease];
		
		annotationView.canShowCallout = NO;
		annotationView.draggable = YES;
		annotationView.selected = YES;
	}
	
	annotationView.annotation = annotation;
	
	return annotationView;
}

#pragma mark - action

- (void) placeSeleted
{
	[self.delegate placeSelected:self.annotation.coordinate];
}

@end
