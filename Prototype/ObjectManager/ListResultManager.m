//
//  ListResultManager.m
//  Prototype
//
//  Created by Adrian Lee on 5/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ListResultManager.h"

#import "Util.h"

@implementation ListResultManager

#pragma mark - overwrite super class method

#pragma mark - overwrite cursor method

- (NSNumber *) newestCursorWithlistID:(NSString *)listID
{
	NSString *objectKey;
	NSNumber *cursor = 0;
	
	NSArray *keyArray = [self.objectKeyArrayDict valueForKey:listID];
	
	if (0 < keyArray.count)
	{
		objectKey = [keyArray objectAtIndex:0];
		cursor = CONVER_NUMBER_FROM_STRING(objectKey);
	}
	
	return cursor;
}

- (NSNumber *) cursorForObject:(NSString *)objectID inlist:(NSString *)listID
{
	return CONVER_NUMBER_FROM_STRING(objectID);
}

- (NSNumber *) oldestCursorWithlistID:(NSString *)listID
{
	NSString *objectKey;
	NSNumber *cursor = 0;
	
	NSArray *keyArray = [self.objectKeyArrayDict valueForKey:listID];
	
	if (0 < keyArray.count)
	{
		objectKey = [keyArray lastObject];
		cursor = CONVER_NUMBER_FROM_STRING(objectKey);
	}
	
	return cursor;
}

#pragma mark - overwrite super classs key method

- (void) updateKeyArrayForList:(NSString *)listID 
		    withResult:(NSArray *)result 
		       forward:(BOOL)forward;
{
	NSDictionary *listDict = [self.objectDict valueForKey:listID];
	
	if (nil != listDict)
	{
		[self.objectKeyArrayDict setValue:[[listDict allKeys] 
						   sortedArrayUsingFunction:LIST_RESULT_SORTER
						   context:listDict] 
					   forKey:listID];
	}
}

@end
