//
//  FoodCommentMananger.m
//  Prototype
//
//  Created by Adrian Lee on 1/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FoodCommentMananger.h"

#import "Util.h"

@implementation FoodCommentMananger

#pragma mark - singelton
DEFINE_SINGLETON(FoodCommentMananger);

#pragma mark - overwrite super class method
#pragma mark - overwrite requsest get method

- (NSString *) getObjectType;
{
	return @"food";
}

@end
