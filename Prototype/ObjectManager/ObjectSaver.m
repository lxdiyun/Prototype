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
#import "ConversationListManager.h"
#import "ConversationManager.h"
#import "PlaceManager.h"
#import "FoodMapListManager.h"
#import "LoginManager.h"
#import "FollowingListManager.h"
#import "FansListManager.h"
#import "UserFoodHistoryManager.h"
#import "Util.h"

typedef enum MSWJ_OBJECT_ENUM
{
	EVENT_MANAGER = 0x0,
	IMAGE_MANAGER = 0x1,
	PROFILE_MANAGER = 0x2,
	FOOD_MANAGER = 0x3,
	FOOD_MAP_LIST_MANAGER = 0x4,
	PLACE_MANAGER = 0x5,
	LOGIN_MANAGER = 0x6,
	FOLLOWING_LIST_MANAGER = 0x7,
	FANS_LIST_MANAGER = 0x8,
	USER_FOOD_HISTORY_MANAGER = 0x9,
//	FOOD_COMMENT_MANAGER = 0xA,
//	CONVERSEATION_LIST_MANAGER = 0xB,
//	CONVERSEATION_MANAGER = 0xC,
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
			LOG(@"Error: %@", nserror);
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
	
	plist = [NSPropertyListSerialization propertyListFromData:plistData
						 mutabilityOption:NSPropertyListMutableContainersAndLeaves
							   format:&format
						 errorDescription:&error];
	if(nil == plist)
	{
		LOG(@"Error: %@", error);
		[error release];
		
		return nil;
	}
	
	return plist;
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

+ (void) resetUserInfo
{
	[EventManager reset];
	[FoodMapListManager reset];
	[ConversationListManager reset];
	[ConversationManager reset];
	[ProfileMananger reset];

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
	MSWJ_OBJECT_CLASS[PLACE_MANAGER] = [PlaceManager class];
	MSWJ_OBJECT_CLASS[LOGIN_MANAGER] = [LoginManager class];
	MSWJ_OBJECT_CLASS[FOLLOWING_LIST_MANAGER] = [FollowingListManager class];
	MSWJ_OBJECT_CLASS[FANS_LIST_MANAGER] = [FansListManager class];
	MSWJ_OBJECT_CLASS[USER_FOOD_HISTORY_MANAGER] = [UserFoodHistoryManager class];
}

+ (void) initialize
{
	[self setupObjectClass];
}

@end
