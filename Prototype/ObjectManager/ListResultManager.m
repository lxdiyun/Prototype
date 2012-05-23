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

#pragma mark - overwrite key and cursor method

- (NSNumber *) cursorForKey:(NSString *)key inList:(NSString *)listID
{
	NSNumber *object = [[self.objectDict valueForKey:listID] valueForKey:key];
	
	return object;
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
