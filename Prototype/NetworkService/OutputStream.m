//
//  OutputStreamDelegate.m
//  Prototype
//
//  Created by Adrian Lee on 12/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "OutputStream.h"

@interface OutputStream (Private)

- (void)writeData;
- (void)closeStream;
@end

@implementation OutputStream

@synthesize data = _data;

#pragma mark - life circle

-(id)initWithDataToWrite:(NSData *)data
{
	self = [super init];
	if (self)
	{
		self.data = data;
	}
	return self;
}

- (void)dealloc 
{
	[self closeStream];
	
	// release object
	self.data = nil;
	self.outputStream = nil;
	
	[super dealloc];
}

#pragma mark - NSStream delegate

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
	NSLog(@"stream event %i", streamEvent);
	
	switch (streamEvent) 
	{
		case NSStreamEventOpenCompleted:
			NSLog(@"Ouput Stream opened");
			break;
			
		case NSStreamEventHasBytesAvailable:
			NSLog(@"Error: output stream receive NSStreamEventHasBytesAvailable event!");
			
		case NSStreamEventHasSpaceAvailable:
			NSLog(@"Ouput stream is ready");
			[self writeData];
			break;
			
		case NSStreamEventErrorOccurred:
			NSLog(@"Can not connect to the host!");
			break;
			
		case NSStreamEventEndEncountered:
			NSLog(@"No buffer left to read!");
			break;
			
		default:
			NSLog(@"Unknown event");
	}
}

- (void)closeStream
{
	if (nil != self.outputStream)
	{
		[self.outputStream close];
		[self.outputStream removeFromRunLoop:[NSRunLoop mainRunLoop] 
					     forMode:NSDefaultRunLoopMode];
		self.outputStream = nil;
	}
}

- (void)writeData
{
	static uint32_t  dataWrited = 0;
	uint32_t totalLength = self.data.length;
	
	
	if (dataWrited < totalLength)
	{
		uint32_t actuallyWritten = 0;
		actuallyWritten = [self.outputStream write:self.data.bytes + dataWrited 
						 maxLength:(totalLength - dataWrited)];
		
		dataWrited += actuallyWritten;
	}
}


@end
