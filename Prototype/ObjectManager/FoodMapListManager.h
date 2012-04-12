//
//  FoodMapListManager.h
//  Prototype
//
//  Created by Adrian Lee on 3/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ListObjectManager.h"

@interface FoodMapListManager : ListObjectManager

+ (void) updateFoodMap:(NSDictionary *)foodMap 
	   withHandler:(SEL)handler 
	     andTarget:target;

@end