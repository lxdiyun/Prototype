//
//  ObjectSaver.m
//  Prototype
//
//  Created by Adrian Lee on 1/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ObjectSaver.h"

#import "EventManager.h"
#import "ImageManager.h"
#import "ProfileMananger.h"
#import "FoodCommentMananger.h"
#import "FoodManager.h"

typedef enum MSWJ_OBJECT_ENUM
{
	EVENT_MANAGER = 0x0,
	IMAGE_MANAGER = 0x1,
	PROFILE_MANAGER = 0x2,
	FOOD_COMMENT_MANAGER = 0x3,
	FOOD_MANAGER = 0x4,
	MSWJ_OBJECT_QUANTITY
} MSWJ_OBJECT;

static Class MSWJ_OBJECT_CLASS[MSWJ_OBJECT_QUANTITY]; 

@implementation ObjectSaver

+ (void) setupObjectClass
{
	MSWJ_OBJECT_CLASS[EVENT_MANAGER] = [EventManager class];
	MSWJ_OBJECT_CLASS[IMAGE_MANAGER] = [ImageManager class];
	MSWJ_OBJECT_CLASS[PROFILE_MANAGER] = [ProfileMananger class];
	MSWJ_OBJECT_CLASS[FOOD_COMMENT_MANAGER] = [FoodCommentMananger class];
	MSWJ_OBJECT_CLASS[FOOD_MANAGER] = [FoodManager class];
}

+ (void) initialize
{
	[self setupObjectClass];
}

+ (void) saveAll
{
	for (int i = 0; i < MSWJ_OBJECT_QUANTITY; ++i)
	{
		[MSWJ_OBJECT_CLASS[i] save];
	}
}

+ (void) restoreAll
{
	for (int i = 0; i < MSWJ_OBJECT_QUANTITY; ++i)
	{
		[MSWJ_OBJECT_CLASS[i] restore];
	}
}

@end
