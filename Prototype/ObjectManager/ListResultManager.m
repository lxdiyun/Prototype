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

- (NSInteger) newestCursorWithlistID:(NSString *)listID
{
	NSString *objectKey;
	NSInteger cursor = 0;
	
	NSArray *keyArray = [self.objectKeyArrayDict valueForKey:listID];
	
	if (0 < keyArray.count)
	{
		objectKey = [keyArray objectAtIndex:0];
		cursor = [[[self.objectDict valueForKey:listID] valueForKey:objectKey] integerValue];
	}
	
	return cursor;
}

- (NSInteger) cursorForObject:(NSString *)objectID inlist:(NSString *)listID
{
	return [[[self.objectDict valueForKey:listID] valueForKey:objectID] integerValue];
}

- (NSInteger) oldestCursorWithlistID:(NSString *)listID
{
	NSString *objectKey;
	NSInteger cursor = 0;
	
	NSArray *keyArray = [self.objectKeyArrayDict valueForKey:listID];
	
	if (0 < keyArray.count)
	{
		objectKey = [keyArray lastObject];
		cursor = [[[self.objectDict valueForKey:listID] valueForKey:objectKey] integerValue];
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
