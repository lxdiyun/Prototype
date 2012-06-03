//
//  Task.m
//  Prototype
//
//  Created by Adrian Lee on 6/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Task.h"

#import "TaskManager.h"

#import "Util.h"

typedef enum TASK_STATUS_ENUM
{
	TASK_STATUS_STOPED = 0x0,
	TASK_STATUS_EXCUTING = 0x1,
	TASK_STATUS_EXCUTED = 0x2,
	TASK_STATUS_MAX
} TASK_STATUS;

typedef enum TASK_COMMAND_ENUM
{
	TASK_START = 0x0,
	TASK_CANCEL = 0x1,
	TASK_CHECK_CONDITION = 0x2,
	TASK_CONFIRM = 0x3,
	TASK_COMMAND_MAX
} TASK_COMMAND;

static SEL gs_stateMahcine[TASK_STATUS_MAX][TASK_COMMAND_MAX];

@interface Task ()
{
	NSString *_taskID;
	TASK_STATUS _state;
}

@property (assign, nonatomic) TASK_STATUS state;

@end

@implementation Task

@synthesize taskID = _taskID;
@synthesize state = _state;

#pragma mark - life circle

- (id) init
{
	self =[super init];
	
	if (nil != self)
	{
		self.state = TASK_STATUS_STOPED;
	}
	
	return self;
}

- (void) dealloc
{
	self.taskID = nil;
	
	[super dealloc];
}

#pragma mark - state machine

+ (void) initialize
{
	gs_stateMahcine[TASK_STATUS_STOPED][TASK_START] = @selector(startWhenStoped);
	gs_stateMahcine[TASK_STATUS_STOPED][TASK_CANCEL] = nil;
	gs_stateMahcine[TASK_STATUS_STOPED][TASK_CHECK_CONDITION] = nil;
	gs_stateMahcine[TASK_STATUS_STOPED][TASK_CONFIRM] = nil;
	
	gs_stateMahcine[TASK_STATUS_EXCUTING][TASK_START] = nil;
	gs_stateMahcine[TASK_STATUS_EXCUTING][TASK_CANCEL] = @selector(cancelWhenExcuting);
	gs_stateMahcine[TASK_STATUS_EXCUTING][TASK_CHECK_CONDITION] = @selector(checkWhenExcuting);
	gs_stateMahcine[TASK_STATUS_EXCUTING][TASK_CONFIRM] = nil;
	
	gs_stateMahcine[TASK_STATUS_EXCUTED][TASK_START] = nil;
	gs_stateMahcine[TASK_STATUS_EXCUTED][TASK_CANCEL] = nil;
	gs_stateMahcine[TASK_STATUS_EXCUTED][TASK_CHECK_CONDITION] = nil;
	gs_stateMahcine[TASK_STATUS_EXCUTED][TASK_CONFIRM] = @selector(confrimWhenExcuted);
}

- (void) startWhenStoped
{
	[TaskManager registTask:self];
	
	self.state = TASK_STATUS_EXCUTING;
}

- (void) cancelWhenExcuting
{
	[TaskManager deregistTask:self];
	
	[self init];
}

- (void) checkWhenExcuting
{
	if ([self isAllConditionReady])
	{
		[self execute];
		
		self.state = TASK_STATUS_EXCUTED;
	}
}

- (void) confrimWhenExcuted
{
	[TaskManager deregistTask:self];
	
	self.state = TASK_STATUS_STOPED;
}

#pragma mark - command interface

- (void) start
{
	SEL command = gs_stateMahcine[self.state][TASK_START];
	
	if (nil != command)
	{
		[self performSelector:command];
	}
}

- (void) checkCondition
{
	SEL command = gs_stateMahcine[self.state][TASK_CHECK_CONDITION];
	
	if (nil != command)
	{
		[self performSelector:command];
	}
}

- (void) cancel
{
	SEL command = gs_stateMahcine[self.state][TASK_CANCEL];
	
	if (nil != command)
	{
		[self performSelector:command];
	}
}

- (void) confirm
{
	SEL command = gs_stateMahcine[self.state][TASK_CONFIRM];
	
	if (nil != command)
	{
		[self performSelector:command];
	}
}

#pragma mark - pure virutal method

- (BOOL) isAllConditionReady
{
	LOG(@"Error %@: need to implement in the sub class",  [self class]);
	
	return NO;
}

- (void) execute
{
	LOG(@"Error %@: need to implement in the sub class",  [self class]);
}



@end
