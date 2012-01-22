//
//  FoodManager.h
//  Prototype
//
//  Created by Adrian Lee on 1/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ObjectManager.h"

@interface FoodManager : ObjectManager

+ (void) createFood:(NSDictionary *)params 
	withHandler:(SEL)handler 
	  andTarget:target;

@end
