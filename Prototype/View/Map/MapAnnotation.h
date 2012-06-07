//
//  MapAnnotation.h
//  Prototype
//
//  Created by Adrian Lee on 3/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <MapKit/MapKit.h>

@interface MapAnnotation : NSObject <MKAnnotation>

@property (strong, nonatomic) NSDictionary *placeObject;
@property (assign, nonatomic) CLLocationCoordinate2D coordinate;

@end
