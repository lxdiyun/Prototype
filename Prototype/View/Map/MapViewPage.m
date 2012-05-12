//
//  MapViewPage.m
//  Prototype
//
//  Created by Adrian Lee on 3/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MapViewPage.h"

#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>

#import "MKMapView+ZoomLevel.h"
#import "Util.h"
#import "FoodMapListManager.h"
#import "PlaceManager.h"
#import "MapAnnotation.h"
#import "PlaceDetailPage.h"
#import "MapAnnotationView.h"

static CGFloat CONST_PLACE_DETAIL_HEIGHT = 265.0;

// caluate accroding to the view size when the view show
static CGFloat PLACE_DETAIL_HEIGHT;
static CGFloat HIDE_PLACE_DETAIL_Y = 1500.0;
static CGFloat SHOW_PLACE_DETAIL_Y;

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

#pragma mark - manage map object

- (void) setMapObject:(NSDictionary *)mapObject
{
	if ([_mapObject isEqualToDictionary:mapObject])
	{
		return;
	}
	
	_mapObject = [mapObject retain];
	
	[self updateGUI];
}

- (void) saveMapObject
{
	@autoreleasepool 
	{
		NSMutableDictionary *newFood = [[self.mapObject mutableCopy] autorelease]; 
		CLLocationCoordinate2D center = self.mapView.centerCoordinate;
		NSUInteger zoomLevel = self.mapView.zoomLevel;

		[newFood setValue:[NSNumber numberWithDouble:center.latitude] forKey:@"lat"];
		[newFood setValue:[NSNumber numberWithDouble:center.longitude] forKey:@"lng"];
		[newFood setValue:[NSNumber numberWithUnsignedInteger: zoomLevel] forKey:@"zoom"];

		for (NSString *key in newFood.allKeys)
		{
			if ([key isEqualToString:@"id"])
			{
				continue;
			}
			else if ([[self.mapObject valueForKey:key] isEqual: [newFood valueForKey:key]]) 
			{
				[newFood setValue:nil forKey:key];
			}
		}

		if ((1 < newFood.count) && (nil != [newFood valueForKey:@"id"]))
		{
			[FoodMapListManager updateFoodMap:newFood withHandler:nil andTarget:nil];
		}
	}	
}

- (void) updateMap
{
	NSString *mapID = [[self.mapObject valueForKey:@"id"] stringValue];
	NSString *loginUserID  = [GET_USER_ID() stringValue];
	NSDictionary *map = nil;
	
	if (nil != mapID)
	{
		map = [FoodMapListManager getObject:mapID inList:loginUserID];
	}
	
	if (nil != map)
	{
		self.mapObject = map;
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

#pragma mark - map location and annotations

- (void) updateGUI
{
	[self removePlaceDetailPage];
	[self.mapView removeAnnotations:self.mapView.annotations];

	self.unAddedPlacesIDArray = [self.mapObject valueForKey:@"places"];
	
	[self addPlaces];
	
	self.title = [self.mapObject valueForKey:@"title"];
	
	[self goToLastCenter];
}

- (void) goToLastCenter
{
	CLLocationCoordinate2D center;
	NSUInteger zoomLevel;
	
	center.latitude = [[self.mapObject valueForKey:@"lat"] doubleValue];
	center.longitude = [[self.mapObject valueForKey:@"lng"] doubleValue];
	zoomLevel = [[self.mapObject valueForKey:@"zoom"] unsignedIntegerValue];
	
	if (0 != zoomLevel)
	{
		[self.mapView setCenterCoordinate:center zoomLevel:zoomLevel animated:YES];
	}
	else 
	{
		[self showAllPlaces];
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

#pragma mark - GUI buttons

- (void) back
{
	[self forcceRemoveDetailPage];
	[self.navigationController popViewControllerAnimated:YES];
}

- (void) setupButtons
{
	// left bar buttons
	UIView *leftButtonView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 81, 30)] autorelease];
	leftButtonView.clipsToBounds = YES;
	UIBarButtonItem *leftButtons = [[[UIBarButtonItem alloc] initWithCustomView:leftButtonView] autorelease];
	// back
	UIButton *backButton = SETUP_BACK_BUTTON(self, @selector(back));
	backButton.frame = CGRectMake(0, 0, 40, 30);
	[leftButtonView addSubview:backButton];
	
	// right bar buttons
	UIView *rightButtonsView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 81, 30)] autorelease];
	rightButtonsView.layer.cornerRadius = 5.0;
	rightButtonsView.clipsToBounds = YES;
	UIBarButtonItem *rightButtons = [[[UIBarButtonItem alloc] initWithCustomView:rightButtonsView] autorelease];
	
	// route
	UIButton *routeButton = SETUP_BUTTON([UIImage imageNamed:@"route.png"], 
					     self, 
					     @selector(focousUserLoaction));
	routeButton.frame = CGRectMake(0, 0, 40, 30);
	routeButton.backgroundColor = [Color grey3Color];
	[rightButtonsView addSubview:routeButton];
	
	// show all places
	UIButton *showAllButton = SETUP_BUTTON([UIImage imageNamed:@"showAllPlace.png"], 
					       self, 
					       @selector(showAllPlaces));
	showAllButton.frame = CGRectMake(41, 0, 40, 30);
	showAllButton.backgroundColor = [Color grey3Color];
	[rightButtonsView addSubview:showAllButton];
	
	// set all buttons
	self.navigationItem.hidesBackButton = YES;
	self.navigationItem.rightBarButtonItem = rightButtons;
	self.navigationItem.leftBarButtonItem = leftButtons;
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
			
			[self setupButtons];
		}
	}

	return self;
}

- (void) dealloc
{
	self.mapView = nil;
	self.mapObject = nil;
	self.unAddedPlacesIDArray = nil;
	self.placeDetailPage = nil;
	self.placeNavco = nil;
	self.menu = nil;

	[super dealloc];
}

- (void) didReceiveMemoryWarning
{
	if (self.navigationController.topViewController 
	    == self.navigationController.visibleViewController)
	{
		// Releases the view if it doesn't have a superview 
		// and the root view is presenting.
		[super didReceiveMemoryWarning];
	}
}

- (void) viewWillAppear:(BOOL)animated
{
	PLACE_DETAIL_HEIGHT = CONST_PLACE_DETAIL_HEIGHT * PROPORTION();
	SHOW_PLACE_DETAIL_Y = [[UIScreen mainScreen] applicationFrame].size.height 
	- (PLACE_DETAIL_HEIGHT / 2) + STATUS_BAR_HEIGHT;

	[super viewWillAppear:animated];
	
	self.focousUser = NO;
}

- (void) viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];

	[self saveMapObject];

	[self forcceRemoveDetailPage];
}

- (void) viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];

	// add the annoation first
	[self updateGUI];
	
	// then show the user location
	self.mapView.showsUserLocation = YES;
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

- (void) mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views 
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

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
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
			placeFrame.origin.y = HIDE_PLACE_DETAIL_Y;
			placeFrame.size.height = PLACE_DETAIL_HEIGHT;
			placeFrame.size.width = self.view.frame.size.width;
			self.placeDetailPage.view.frame = placeFrame;

			[self.navigationController.tabBarController.view addSubview:self.placeDetailPage.view];
		}


		// show the view
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];  
		
		CGPoint placeDetailPageCenter  = self.placeDetailPage.view.center;
		placeDetailPageCenter.y = SHOW_PLACE_DETAIL_Y;
		
		self.placeDetailPage.view.center = placeDetailPageCenter;
		
		[self performSelector:@selector(resizeSmallAndShowSelectedPlaces) withObject:nil afterDelay:0.5];
		
		[UIView commitAnimations];
	}
}

- (void) forcceRemoveDetailPage
{
	CGPoint placeDetailPageCenter  = self.placeDetailPage.view.center;
	placeDetailPageCenter.y = HIDE_PLACE_DETAIL_Y;
	
	self.placeDetailPage.view.center = placeDetailPageCenter;
	
	[self.placeDetailPage.view removeFromSuperview];
	
	self.selectedPlace = NO;
}

- (void) removePlaceDetailPage
{
	if (YES == self.selectedPlace)
	{
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];

		CGPoint placeDetailPageCenter  = self.placeDetailPage.view.center;
		placeDetailPageCenter.y = HIDE_PLACE_DETAIL_Y;

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
			CLLocationCoordinate2D dest = selectedAnnotation.coordinate;
			CLLocationCoordinate2D src;
			
			if (0 < self.mapView.userLocation.location.horizontalAccuracy)
			{
				
				src = self.mapView.userLocation.coordinate;
			}
			else 
			{
				src = self.mapView.centerCoordinate;
			}
			
			NSString *destlatlong = [NSString stringWithFormat:@"%lf,%lf", dest.latitude, dest.longitude];
			NSString *srclatlong = [NSString stringWithFormat:@"%lf,%lf", src.latitude, src.longitude];
			
			NSString *url = [NSString stringWithFormat: @"http://maps.google.com/maps?saddr=%@&daddr=%@",
					 [srclatlong stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
					 [destlatlong stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
			
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
- (void) updateUserLocation:(MKUserLocation *)userLocation
{
	CLLocationAccuracy accuracy = userLocation.location.horizontalAccuracy;

	if (accuracy > 0 ) 
	{
		MKMapPoint userPoint = MKMapPointForCoordinate(userLocation.location.coordinate);
		MKMapRect currentRect = [self.mapView visibleMapRect];
		
		self.focousUser = NO;
		
		if (!MKMapRectContainsPoint(currentRect, userPoint))
		{
			[self.mapView setCenterCoordinate:userLocation.location.coordinate animated:YES];
		}
	}
}


- (void) focousUserLoaction
{
	self.mapView.showsUserLocation = NO;

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
