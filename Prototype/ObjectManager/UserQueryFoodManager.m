//
//  UserQueryFoodManager.m
//  Prototype
//
//  Created by Adrian Lee on 5/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UserQueryFoodManager.h"
#import "FoodManager.h"

@implementation UserQueryFoodManager

#pragma mark - overwrite super class method
#pragma mark - overwrite handler

- (void) getMethodHandler:(id)result withListID:(NSString *)listID forward:(BOOL)forward
{
	@autoreleasepool 
	{
		NSDictionary *messageDict = [(NSDictionary*)result retain];
		NSDictionary *listDict = [self.objectDict valueForKey:listID];
		
		if (nil == listDict)
		{
			listDict = [[NSMutableDictionary alloc] init];
			[self.objectDict setValue:listDict forKey:listID];
			[listDict autorelease];
		}
		
		for (NSDictionary *object in [messageDict objectForKey:@"result"]) 
		{
			NSDictionary *food = [object valueForKey:@"food"];
			NSNumber *foodID = [food valueForKey:@"id"];
			NSNumber *sortIndex = [object valueForKey:@"id"];
			
			[listDict setValue:sortIndex forKey:[foodID stringValue]];
			
			if (nil != food)
			{
				[FoodManager setObject:food withNumberID:foodID];
			}
		}
		
		// update object key array
		[self updateKeyArrayForList:listID withResult:nil forward:forward];
		
		[messageDict release];
	}
}

#pragma mark - overwrite super classs get method

- (void) configGetMethodParams:(NSMutableDictionary *)params forList:(NSString *)listID
{
	@autoreleasepool 
	{
		[params setValue:[NSNumber numberWithInt:[listID intValue]] forKey:@"user"];
	}
	
}

@end
