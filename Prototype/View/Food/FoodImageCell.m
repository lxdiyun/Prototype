//
//  FoodImageCell.m
//  Prototype
//
//  Created by Adrian Lee on 12/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "FoodImageCell.h"

@implementation FoodImageCell
@synthesize foodImage;

- (void)dealloc {
	[foodImage release];
	[super dealloc];
}
@end
