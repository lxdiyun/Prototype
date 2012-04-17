//
//  MapAnnotationView.h
//  Prototype
//
//  Created by Adrian Lee on 4/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <MapKit/MapKit.h>

@protocol  MapAnnotationDelegate;

@interface MapAnnotationView : MKAnnotationView

@property (assign) id<MapAnnotationDelegate> delegate;

- (void) markSelected;
- (void) markUnSelected;

@end

@protocol  MapAnnotationDelegate

- (void) retap:(MapAnnotationView *)annotationView;

@end
