//
//  TaskManager.m
//  Prototype
//
//  Created by Adrian Lee on 6/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TaskManager.h"

#import "Util.h"

@interface TaskManager ()
{
	NSMutableDictionary *_tasks;
	NSInteger _currentTaskID;
}

@property (strong, nonatomic) NSMutableDictionary *tasks;
@property (assign, nonatomic) NSInteger currentTaskID;

@end

@implementation TaskManager

@synthesize tasks = _tasks;
@synthesize currentTaskID = _currentTaskID;

#pragma mark - singleton

DEFINE_SINGLETON(TaskManager);

#pragma mark - life circle

- (id) init
{
	self = [super init];
	
	if (nil != self)
	{
		NSMutableDictionary *tasks = [[NSMutableDictionary alloc] init];
		
		self.tasks = tasks;
		
		[tasks release];
	}

	return self;
}

- (void) dealloc
{
	self.tasks = nil;
	
	[super dealloc];
}

#pragma mark - taskID

- (NSString *) genTaskID
{	
	NSString *taskID = [NSString stringWithFormat:@"%d", self.currentTaskID++];
	
	return taskID;
}

#pragma mark - regist / deregist 

+ (void) registTask:(Task *)task
{
	if (nil != task)
	{
		NSString *newtaskID = [[self getInstnace] genTaskID];
		
		task.taskID = newtaskID;
		
		[[[self getInstnace] tasks] setValue:task forKey:newtaskID];
	}
	
}

+ (void) deregistTask:(Task *)task
{
	if (nil != task.taskID)
	{
		[[[self getInstnace] tasks] setValue:nil forKey:task.taskID];
		task.taskID = nil;
	}
}


@end
