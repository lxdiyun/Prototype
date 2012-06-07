//
//  PlaceManager.h
//  Prototype
//
//  Created by Adrian Lee on 3/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ObjectManager.h"

@interface PlaceManager : ObjectManager

+ (void) createPlace:(NSDictionary *)placeObject withHandler:(SEL)handler andTarget:(id)target;

@end
