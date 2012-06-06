//
//  ObjectSaver.m
//  Prototype
//
//  Created by Adrian Lee on 1/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ObjectSaver.h"

#import "ConversationListManager.h"
#import "ConversationManager.h"
#import "EventManager.h"
#import "FoodCommentMananger.h"
#import "FoodManager.h"
#import "FoodMapListManager.h"
#import "ImageManager.h"
#import "LoginManager.h"
#import "PlaceManager.h"
#import "ProfileMananger.h"
#import "PublicFoodMapListManager.h"
#import "UserFoodHistoryManager.h"
#import "Util.h"

typedef enum MSWJ_OBJECT_ENUM
{
	EVENT_MANAGER = 0x0,
	IMAGE_MANAGER = 0x1,
	PROFILE_MANAGER = 0x2,
	FOOD_MANAGER = 0x3,
	FOOD_MAP_LIST_MANAGER = 0x4,
	PUBLIC_FOOD_MAP_LIST_MANAGER = 0x5,
	PLACE_MANAGER = 0x6,
	LOGIN_MANAGER = 0x7,
	USER_FOOD_HISTORY_MANAGER = 0x8,
//	FOOD_COMMENT_MANAGER = 0xFFF,
//	CONVERSEATION_LIST_MANAGER = 0xFFF,
//	CONVERSEATION_MANAGER = 0xFFF,
	MSWJ_OBJECT_QUANTITY
} MSWJ_OBJECT;

static Class MSWJ_OBJECT_CLASS[MSWJ_OBJECT_QUANTITY]; 

@implementation ObjectSaver

#pragma mark - Application's Documents directory


+ (NSString *) applicationCacheDirectory 
{
	return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
}

#pragma mark - save and restore plist

+ (void) saveData:(NSDictionary *)dict
{
	NSString *path = [[self applicationCacheDirectory] 
			  stringByAppendingPathComponent:@"DataCache.plist"];
	NSData *plistData;
	NSString *error;
	
	plistData = [NSPropertyListSerialization dataFromPropertyList:dict
							       format:NSPropertyListBinaryFormat_v1_0
						     errorDescription:&error];
	if(nil != plistData) 
	{
		[plistData writeToFile:path atomically:YES];
		NSError *nserror = nil;
		[plistData writeToFile:path options:NSDataWritingFileProtectionComplete error:&nserror];
		
		if (nil != nserror)
		{
			LOG(@"Error: %@ data = \n%@", error, dict);
			[error release];
		}
	}
	else 
	{
		LOG(@"Error: %@ data = \n%@", error, dict);
		[error release];
	}
}

+ (NSMutableDictionary *) restoreData
{
	NSString *path = [[self applicationCacheDirectory] 
			  stringByAppendingPathComponent:@"DataCache.plist"];
	NSData *plistData = [NSData dataWithContentsOfFile:path];
	NSString *error;
	NSPropertyListFormat format = NSPropertyListBinaryFormat_v1_0;
	NSMutableDictionary *plist;
	
	plist = [[NSPropertyListSerialization propertyListFromData:plistData
						 mutabilityOption:NSPropertyListMutableContainersAndLeaves
							   format:&format
						 errorDescription:&error] retain];
	if(nil == plist)
	{
		LOG(@"Error: %@", error);
		[error release];
		
		return nil;
	}
	
	return [plist autorelease];
}


#pragma mark - interface

+ (void) saveAll
{
	@autoreleasepool 
	{
		NSMutableDictionary *objectDicitionary = [[NSMutableDictionary alloc] init];
		
		for (int i = 0; i < MSWJ_OBJECT_QUANTITY; ++i)
		{
			[MSWJ_OBJECT_CLASS[i] saveTo:objectDicitionary];
		}
		
		[self saveData:objectDicitionary];
		
		[objectDicitionary release];
	}
}

+ (void) restoreAll
{
	@autoreleasepool 
	{
		NSMutableDictionary *objectDicitionary = [self restoreData];
		
		if (nil != objectDicitionary)
		{
			for (int i = 0; i < MSWJ_OBJECT_QUANTITY; ++i)
			{
				[MSWJ_OBJECT_CLASS[i] restoreFrom:objectDicitionary];
			}
		}
	}
	
}

+ (void) resetCache
{
	for (int i = 0; i < MSWJ_OBJECT_QUANTITY; ++i)
	{
		[MSWJ_OBJECT_CLASS[i] reset];
	}
	
	[ConversationListManager reset];
	[ConversationManager reset];

	[self saveAll];
}

#pragma mark - life circle

+ (void) setupObjectClass
{
	MSWJ_OBJECT_CLASS[EVENT_MANAGER] = [EventManager class];
	MSWJ_OBJECT_CLASS[IMAGE_MANAGER] = [ImageManager class];
	MSWJ_OBJECT_CLASS[PROFILE_MANAGER] = [ProfileMananger class];
	MSWJ_OBJECT_CLASS[FOOD_MANAGER] = [FoodManager class];
	MSWJ_OBJECT_CLASS[FOOD_MAP_LIST_MANAGER] = [FoodMapListManager class];
	MSWJ_OBJECT_CLASS[PUBLIC_FOOD_MAP_LIST_MANAGER] = [PublicFoodMapListManager class];
	MSWJ_OBJECT_CLASS[PLACE_MANAGER] = [PlaceManager class];
	MSWJ_OBJECT_CLASS[LOGIN_MANAGER] = [LoginManager class];
	MSWJ_OBJECT_CLASS[USER_FOOD_HISTORY_MANAGER] = [UserFoodHistoryManager class];
}

+ (void) initialize
{
	[self setupObjectClass];
}

@end
