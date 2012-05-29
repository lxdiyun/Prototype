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

@interface InputMapPage : UIViewController

@property (strong, nonatomic) MapAnnotation *annotation;

@property (retain, nonatomic) IBOutlet MKMapView *map;

@end
