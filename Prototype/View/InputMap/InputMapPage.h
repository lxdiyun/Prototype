//
//  InputMapPage.h
//  Prototype
//
//  Created by Adrian Lee on 5/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "MapAnnotation.h"

@protocol InputMapDelegate <NSObject>

- (void) placeSelected:(CLLocationCoordinate2D)coordinate;

@end

@interface InputMapPage : UIViewController

- (void) reset;

@property (strong, nonatomic) MapAnnotation *annotation;
@property (strong, nonatomic) NSString *placeName;
@property (strong, nonatomic) NSString *city;
@property (assign, nonatomic) id<InputMapDelegate> delegate;

@property (retain, nonatomic) IBOutlet MKMapView *map;


@end
