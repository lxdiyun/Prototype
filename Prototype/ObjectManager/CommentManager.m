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

}


@end

@implementation CommentManager

@synthesize objectTypeString;

#pragma mark - life circle

+ (id) getInstnace
{
	LOG(@"Error should use the subclass method");
	return nil;
}

- (id) init
{
	self = [super init];

	if (nil != self)
	{
		@autoreleasepool 
		{
			self.createMethodString = @"comment.create";
			self.getMethodString = @"comment.get";
			self.objectTypeString = nil;
		}
	}
	
	return self;
}


- (void) dealloc
{
	self.objectTypeString = nil;
	
	[super dealloc];
}

#pragma mark - class interface
+ (void) createComment:(NSString *)text forList:(NSString *)listID withHandler:(SEL)handler andTarget:target
{
	@autoreleasepool 
	{
		
		
		NSMutableDictionary *newComment = [[[NSMutableDictionary alloc] init] autorelease];
		
		[newComment setValue:text forKey:@"msg"];
		[newComment setValue:[NSNumber numberWithInt:[listID intValue]]  forKey:@"obj_id"];
		[newComment setValue:[[self getInstnace] objectTypeString] forKey:@"obj_type"];
		
		[self requestCreateWithObject:newComment inList:listID withHandler:handler andTarget:target];
	}
}


#pragma mark - overwrite super class method
#pragma mark - overwrite handler

- (void) getMethodHandler:(id)dict withListID:(NSString *)listID forward:(BOOL)forward
{
	[super getMethodHandler:dict withListID:listID forward:forward];
	
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

- (void) configGetMethodParams:(NSMutableDictionary *)params forList:(NSString *)listID
{
	@autoreleasepool 
	{
		[params setValue:self.objectTypeString forKey:@"obj_type"];
		[params setValue:[NSNumber numberWithInt:[listID intValue]] forKey:@"obj_id"];
	}
	
}

@end
