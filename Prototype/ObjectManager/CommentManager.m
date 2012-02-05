//
//  CommentManager.m
//  Prototype
//
//  Created by Adrian Lee on 1/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CommentManager.h"

#import "ProfileMananger.h"
#import "Util.h"

@interface CommentManager ()
{
	NSString *_createCommentString;
}
@property (strong) NSString *createCommentString;

@end

@implementation CommentManager

@synthesize createCommentString = _createCommentString;

#pragma mark - life circle

+ (id) getInstnace
{
	LOG(@"Error should use the subclass method");
	return nil;
}

- (void) dealloc
{
	self.createCommentString = nil;
}

#pragma mark - class interface
+ (void) createComment:(NSString *)text forList:(NSString *)listID withHandler:(SEL)handler andTarget:target
{
	[[self getInstnace] setCreateCommentString:text];

	[self requestCreateWithListID:listID withHandler:handler andTarget:target];
}

#pragma mark - method that must be overwrite by subclass
- (NSString *) getObjectType;
{
	LOG(@"Error should use the subclass method");
	return nil;
}

#pragma mark - overwrite super class method
#pragma mark - overwrite handler

- (void) getMethodHandler:(id)dict withListID:(NSString *)ID forward:(BOOL)forward
{
	[super getMethodHandler:dict withListID:ID forward:forward];
	
	NSDictionary *messageDict = [(NSDictionary*)dict retain];
	NSMutableSet *newUserSet = [[NSMutableSet alloc] init];
	
	for (NSDictionary *object in [messageDict objectForKey:@"result"]) 
	{
		NSNumber *userID = [object valueForKey:@"user"];
		if (CHECK_NUMBER(userID))
		{
			if (nil == [ProfileMananger getObjectWithNumberID:userID])
			{
				[newUserSet addObject:userID];
			}
		}
		else
		{
			LOG(@"Error failed to get userID from \n:%@", object);
		}
		
	}
	
	// buffer the new image info
	[ProfileMananger requestObjectWithNumberIDArray:[newUserSet allObjects]];
	
	[newUserSet release];
	[messageDict release];
}


#pragma mark - overwrite super classs get method

- (NSString *) getMethod
{
	return @"comment.get";
}

- (void) setGetMethodParams:(NSMutableDictionary *)params forList:(NSString *)listID
{
	@autoreleasepool 
	{
		[params setValue:[self getObjectType] forKey:@"obj_type"];
		[params setValue:[NSNumber numberWithInt:[listID intValue]] forKey:@"obj_id"];
	}
	
}

#pragma mark - overwrite super classs create method

- (NSString *) createMethod
{
	return @"comment.create";
}

- (void) setCreateMethodParams:(NSMutableDictionary *)params forList:(NSString *)listID
{
	@autoreleasepool 
	{
		[params setValue:[self getObjectType] forKey:@"obj_type"];
		[params setValue:[NSNumber numberWithInt:[listID intValue]] forKey:@"obj_id"];
		[params setValue:self.createCommentString forKey:@"msg"];
	}
}

@end
