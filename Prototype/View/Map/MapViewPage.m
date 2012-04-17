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
#import "PlaceDetailPage.h"
#import "MapAnnotationView.h"

static CGFloat PLACE_DETAIL_HEIGHT = 265.0;

typedef enum MAP_MENU_ENUM
{
	SHOW_ALL_PLACE = 0x0,
	SHOW_WHERE_AM_I = 0x1,
	REFRESH = 0x2,
	MAP_MENU_MAX
} MAP_MENU;

@interface MapViewPage () <MKMapViewDelegate, PlaceDetailDelegate, MapAnnotationDelegate, UIActionSheetDelegate>
{
	MKMapView *_mapView;
	BOOL _focousUser;
	NSDictionary *_mapObject;
	NSArray *_unAddedPlacesIDArray;
	PlaceDetailPage *_placeDetailPage;
	UINavigationController *_placeNavco;
	BOOL _selectedPlace;
	UIActionSheet *_menu;
}

@property (strong) MKMapView *mapView;
@property (assign) BOOL focousUser;
@property (strong) NSArray *unAddedPlacesIDArray;
@property (strong) PlaceDetailPage *placeDetailPage;
@property (strong) UINavigationController *placeNavco;
@property (assign) BOOL selectedPlace;
@property (strong) UIActionSheet *menu;

- (void) showPlaces:(NSArray *)annotations;
- (void) showPlaceDetailPage;
- (void) removePlaceDetailPage;

@end

@implementation MapViewPage

@synthesize mapView = _mapView;
@synthesize focousUser = _focousUser;
@synthesize mapObject = _mapObject;
@synthesize unAddedPlacesIDArray = _unAddedPlacesIDArray;
@synthesize placeDetailPage = _placeDetailPage;
@synthesize placeNavco = _placeNavco;
@synthesize selectedPlace = _selectedPlace;
@synthesize menu = _menu;

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
					      withHandler:@selector(updateMap) 
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

- (void) updateMap
{
	NSString *mapID = [[self.mapObject valueForKey:@"id"] stringValue];
	NSString *loginUserID  = [GET_USER_ID() stringValue];
	
	[self removePlaceDetailPage];
	[self.mapView removeAnnotations:self.mapView.annotations];

	self.mapObject = [FoodMapListManager getObject:mapID inList:loginUserID];

	if (nil != self.mapObject)
	{
		self.unAddedPlacesIDArray = [self.mapObject valueForKey:@"places"];

		[self addPlaces];

		self.title = [self.mapObject valueForKey:@"title"];
	}
}

#pragma mark - life circle

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

	if (self) 
	{
		@autoreleasepool 
		{
			PLACE_DETAIL_HEIGHT = PLACE_DETAIL_HEIGHT * PROPORTION();

			self.mapView = [[[MKMapView alloc] init] autorelease];
			self.view = self.mapView;
			self.mapView.delegate = self;

			UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backArrow.png"] 
										 style:UIBarButtonItemStylePlain 
										target:self.navigationController 
										action:@selector(popViewControllerAnimated:)];

			UIBarButtonItem *route = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"route.png"] 
										  style:UIBarButtonItemStylePlain 
										 target:self
										 action:@selector(focousUserLoaction)];

			UIBarButtonItem *showAllPlaces = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"showAllPlace.png"] 
											  style:UIBarButtonItemStylePlain 
											 target:self
											 action:@selector(showAllPlaces)];

			UIBarButtonItem *refresh = [[[UIBarButtonItem alloc] 
				initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
						     target:self
						     action:@selector(reloadMapObject)] 
						     autorelease];


			self.navigationItem.rightBarButtonItems = [[NSArray alloc] initWithObjects:showAllPlaces,route, nil];

			self.navigationItem.leftBarButtonItems = [[NSArray alloc] initWithObjects:back, refresh, nil];
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

	[self removePlaceDetailPage];
}

- (void) viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];

	[self goToLastCenter];

	[self updateMap];
}

- (void) viewDidLoad
{
	[super viewDidLoad];

	self.selectedPlace = NO;
}

- (void) viewDidUnload
{
	self.mapView = nil;
	self.mapObject = nil;
	self.unAddedPlacesIDArray = nil;
	self.placeDetailPage = nil;
	self.placeNavco = nil;
	self.menu = nil;

	[super viewDidUnload];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views 
{ 
	NSTimeInterval duration = 0.1;
	NSInteger durationCount = 0;
	NSArray *sortedViews = [views sortedArrayUsingFunction:MAP_ANNOTATION_VIEW_SORTER context:nil];

	for (MKAnnotationView *aV in sortedViews) 
	{
		CGRect endFrame = aV.frame;
		++durationCount;

		aV.frame = CGRectOffset(endFrame, 0, -500);

		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:duration * durationCount];
		[UIView setAnimationCurve:UIViewAnimationCurveLinear];
		[aV setFrame:endFrame];
		[UIView commitAnimations];

	}
}

- (void) mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation      
{
	if (self.focousUser)
	{
		[self updateUserLocation:userLocation];

		self.focousUser = NO;
	}
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
	// if it's the user location, just return nil.
	if ([annotation isKindOfClass:[MKUserLocation class]])
		return nil;

	// try to dequeue an existing pin view first
	static NSString* annotationViewIdentifier = @"MapAnnotationView";
	MapAnnotationView* annotationView = (MapAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationViewIdentifier];

	if (nil == annotationView)
	{
		// if an existing pin view was not available, create one
		annotationView = [[[MapAnnotationView alloc]
			initWithAnnotation:annotation reuseIdentifier:annotationViewIdentifier] autorelease];

		annotationView.canShowCallout = YES;

		UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
		[rightButton addTarget:self
				action:@selector(showInSystemMap)
		      forControlEvents:UIControlEventTouchUpInside];
		annotationView.rightCalloutAccessoryView = rightButton;
		annotationView.delegate = self;
	}

	annotationView.annotation = annotation;

	return annotationView;
}

- (void) mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
	if ([view isKindOfClass:[MapAnnotationView class]]) 
	{
		MapAnnotationView *annotationView = (MapAnnotationView *)view;
		MapAnnotation *mapAnnotation = view.annotation;

		[annotationView markSelected];

		[self showPlaceDetail:mapAnnotation.placeObject];
	}
}

- (void) mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
	if ([view isKindOfClass:[MapAnnotationView class]]) 
	{
		MapAnnotationView *annotationView = (MapAnnotationView *)view;

		[annotationView markUnSelected];

		[self performSelector:@selector(checkAndRemoveDetailPlace) withObject:nil afterDelay:0.1];
	}
}


#pragma mark - place detail page

- (void) showPlaceDetail:(NSDictionary *)placeObject
{	
	if (0 < [[placeObject valueForKey:@"foods"] count])
	{
		if (nil == self.placeDetailPage)
		{
			PlaceDetailPage *placeDetailPage = [[PlaceDetailPage alloc] init];
			placeDetailPage.delegate = self;

			self.placeDetailPage = placeDetailPage;

			[placeDetailPage release];
		}

		self.placeDetailPage.placeObject = placeObject;

		[self showPlaceDetailPage];
	}
	else 
	{
		[self removePlaceDetailPage];
	}
}

- (void) showSelectedPlaces
{
	CLLocationCoordinate2D coordinate = [[self.mapView.selectedAnnotations objectAtIndex:0] coordinate];
	CGPoint fakecenter = [self.mapView convertCoordinate:coordinate toPointToView:self.mapView];

	fakecenter.y += 60 * PROPORTION();
	coordinate = [self.mapView convertPoint:fakecenter toCoordinateFromView:self.mapView];

	[self.mapView setCenterCoordinate:coordinate animated:YES];
}

- (void) resizeSmallAndShowSelectedPlaces
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.2]; 

	[self showSelectedPlaces];

	[UIView commitAnimations];
}

- (void) showPlaceDetailPage
{
	if (NO == self.selectedPlace)
	{
		self.selectedPlace = YES;

		if (self.navigationController.tabBarController.view != self.placeDetailPage.view.superview)
		{
			CGRect placeFrame = self.navigationController.tabBarController.view.frame;
			placeFrame.origin.y = placeFrame.size.height;
			placeFrame.size.height = PLACE_DETAIL_HEIGHT;
			placeFrame.size.width = self.view.frame.size.width;
			self.placeDetailPage.view.frame = placeFrame;
			[self.navigationController.tabBarController.view addSubview:self.placeDetailPage.view];
		}

		{
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:0.2];  

			CGPoint placeDetailPageCenter  = self.placeDetailPage.view.center;
			placeDetailPageCenter.y = self.navigationController.tabBarController.view.frame.size.height - PLACE_DETAIL_HEIGHT / 2;

			self.placeDetailPage.view.center = placeDetailPageCenter;

			[self performSelector:@selector(resizeSmallAndShowSelectedPlaces) withObject:nil afterDelay:0.5];

			[UIView commitAnimations];
		}
	}
}

- (void) removePlaceDetailPage
{
	if (YES == self.selectedPlace)
	{
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];

		CGPoint placeDetailPageCenter  = self.placeDetailPage.view.center;
		placeDetailPageCenter.y = self.navigationController.tabBarController.view.frame.size.height + PLACE_DETAIL_HEIGHT;

		self.placeDetailPage.view.center = placeDetailPageCenter;

		[UIView commitAnimations];

		self.selectedPlace = NO;
	}
}

- (void) checkAndRemoveDetailPlace
{
	if (0 >= self.mapView.selectedAnnotations.count)
	{
		id selectedAnnotation = [self.mapView.selectedAnnotations objectAtIndex:0];

		if (![selectedAnnotation isKindOfClass:[MapAnnotation class]]) 
		{
			[self removePlaceDetailPage];
		}
	}
}

#pragma mark - PlaceDetailDelegate

- (void) placeDetailPagePullDown
{
	[self removePlaceDetailPage];
}

#pragma mark - MapAnnotationDelegate

- (void) retap:(MapAnnotationView *)annotationView
{
	[self showPlaceDetailPage];
}

#pragma mark - map menu

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

- (void) showAllPlaces
{
	[self removePlaceDetailPage];

	[self showPlaces:self.mapView.annotations];
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
			MKMapPoint userPoint = MKMapPointForCoordinate(userLocation.location.coordinate);
			MKMapRect currentRect = [self.mapView visibleMapRect];
			
			if (!MKMapRectContainsPoint(currentRect, userPoint))
			{
				[self.mapView setCenterCoordinate:userLocation.location.coordinate animated:YES];
			}
		}
		else 
		{
			[self performSelector:@selector(focousUserLoaction) withObject:nil afterDelay:1.0];
		}
	}
}


- (void) focousUserLoaction
{
	self.focousUser = YES;
	self.mapView.showsUserLocation = YES;

	[self removePlaceDetailPage];
	[self updateUserLocation:self.mapView.userLocation];
}

- (void) showMapMenu
{
	@autoreleasepool 
	{
		if (nil == self.menu)
		{
			self.menu = [[[UIActionSheet alloc] initWithTitle:nil 
								 delegate:self 
							cancelButtonTitle:nil 
						   destructiveButtonTitle:nil 
							otherButtonTitles:nil] 
							autorelease];

			self.menu.actionSheetStyle = UIActionSheetStyleBlackTranslucent;

			[self.menu addButtonWithTitle:@"显示所有地点"];
			[self.menu addButtonWithTitle:@"我在哪？"];
			[self.menu addButtonWithTitle:@"刷新"];
			[self.menu addButtonWithTitle:@"取消"];
			self.menu.cancelButtonIndex = MAP_MENU_MAX;

			self.menu.delegate = self;
		}

		[self removePlaceDetailPage];
		[self.menu showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
	}
}

#pragma mark - UIActionSheetDelegate
- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	switch (buttonIndex) 
	{
	case SHOW_ALL_PLACE:
		[self showAllPlaces];
		break;
	case SHOW_WHERE_AM_I:
		[self focousUserLoaction];
		break;
	case REFRESH:
		[self reloadMapObject];
		break;
	default:
			[self.menu dismissWithClickedButtonIndex:MAP_MENU_MAX animated:YES];
			break;
	}
}

@end
