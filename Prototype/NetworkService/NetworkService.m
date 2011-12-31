//
//  NetworkService.m
//  Prototype
//
//  Created by Adrian Lee on 12/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.

#import "NetworkService.h"


#import "Util.h"
#import "LoginMessage.h"
#import "Message.h"

@interface NetworkService () <NSStreamDelegate>
{
	NSInputStream *_inputStream;
	NSOutputStream *_outputStream;
	NSMutableArray *_wrtieArray;
	LoginMessage *_loginMessage;

	BOOL _isWriting;
	BOOL _connectionRest;
}

@property (retain) NSInputStream *inputStream;
@property (retain) NSOutputStream *outputStream;
@property (retain) NSMutableArray *writeArray;
@property (retain) LoginMessage *loginMessage;
@property (assign) BOOL isWriting;
@property (assign) BOOL connectionRest;

// initialization
- (void) setup;
- (void) connect;
- (void) closeStream;

// write
- (void) writeMessage;

// read
- (void) readMessage;

@end

@implementation NetworkService

@synthesize inputStream = _inputStream;
@synthesize outputStream = _outputStream;
@synthesize writeArray = _wrtieArray;
@synthesize isWriting = _isWriting;
@synthesize loginMessage = _loginMessage;
@synthesize connectionRest = _connectionRest;

#pragma mark -
#pragma mark Singleton Methods

static NetworkService *gs_shared_instance = nil;

+ (void) initialize 
{
	if (self == [NetworkService class]) 
	{
		gs_shared_instance = [[super allocWithZone:nil] init];
		[gs_shared_instance setup];
	}
}

+ (id) allocWithZone:(NSZone *)zone 
{
	return [gs_shared_instance retain];
}

- (id) copyWithZone:(NSZone *)zone 
{
	return self;
}

#if (!__has_feature(objc_arc))

- (id) retain 
{
	return self;
}

- (unsigned) retainCount
{
	return UINT_MAX;  //denotes an object that cannot be released
}

- (oneway void) release 
{
	//do nothing
}

- (id) autorelease 
{
	return self;
}
#endif

#pragma mark -
#pragma mark Custom Methods

// Add your custom methods here

- (void) setup
{
	// init data
	{
		NSMutableArray *tempArray = [[NSMutableArray alloc] init];
		self.writeArray = tempArray;
		[tempArray release];

		LoginMessage *loginMessage = [[LoginMessage alloc] init];
		self.loginMessage = loginMessage;
		[loginMessage release];

		self.isWriting = NO;
	}

	[self connect];
}

- (void) dealloc 
{

	[self closeStream];

	// release object
	self.inputStream = nil;
	self.outputStream = nil;
	self.writeArray = nil;
	self.loginMessage = nil;

	[super dealloc];
}

#pragma mark - private connection method

- (void) connect 
{
	[self closeStream];

	CFReadStreamRef readStream;
	CFWriteStreamRef writeStream;
	// TODO: replace the network host address
	CFStreamCreatePairWithSocketToHost(NULL, 
					   (CFStringRef)@"175.156.203.104", 
					   4040, 
					   &readStream, 
					   &writeStream);
	self.inputStream = (NSInputStream *)readStream;
	self.outputStream = (NSOutputStream *)writeStream;

	[self.inputStream setDelegate:self];
	[self.outputStream setDelegate:self];

	// change runloop mode to default if gui interaction is more importang
	// don't forget the close method
	[self.inputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] 
				    forMode:NSRunLoopCommonModes];
	[self.outputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] 
				     forMode:NSRunLoopCommonModes];
	[self.inputStream open];
	[self.outputStream open];

	self.connectionRest = YES;

	[self.loginMessage request];
}

- (void) closeStream
{
	if (nil != self.inputStream)
	{
		[self.inputStream close];
		[self.inputStream removeFromRunLoop:[NSRunLoop mainRunLoop] 
					    forMode:NSRunLoopCommonModes];
		self.inputStream = nil;
	}
	
	if (nil != self.outputStream)
	{
		[self.outputStream close];
		[self.outputStream removeFromRunLoop:[NSRunLoop mainRunLoop] 
					     forMode:NSRunLoopCommonModes];
		self.outputStream = nil;
	}
}

#pragma mark - NSstream delegate

- (void) stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent 
{
	// TODO remove log
	switch (streamEvent) 
	{
	case NSStreamEventOpenCompleted:
		// LOG(@"Stream opened");
		break;

	case NSStreamEventHasBytesAvailable:
		// LOG(@"Input Stream ready");
		[self readMessage];
		break;

	case NSStreamEventHasSpaceAvailable:
		// LOG(@"Ouput stream is ready");
		[self writeMessage];
		break;

	case NSStreamEventErrorOccurred:
		LOG(@"Error Can not connect to the host!");
		STOP_PING();
		CLEAR_MESSAGE_HANDLER();
		[self connect];
		break;

	case NSStreamEventEndEncountered:
		LOG(@"Error No buffer left to read!");
		break;

	default:
		LOG(@"Error Unknown event %i", streamEvent);
	}
}

#pragma mark - write methods

- (void) requestSendMessage:(NSData *)message
{
	if (nil != message)
	{
		[self.writeArray addObject:message];

		if ([self.outputStream hasSpaceAvailable])
		{
			[self writeMessage];
		}
	}
}

- (void) writeMessage
{
	@synchronized(self)
	{
		if (self.isWriting)
		{
			return;
		}

		self.isWriting = YES;
	}

	static uint32_t offset;
	static uint32_t bufferLength = 0;
	static NSData *buffer;

	if (0 == bufferLength)
	{

		if (0 == [self.writeArray count])
		{
			// have no buffer to write, just reutun
			self.isWriting = NO;

			return;
		}

		buffer = [self.writeArray objectAtIndex:0];
		bufferLength = buffer.length;
		offset = 0;
	}

	if (0 < bufferLength)
	{
		uint32_t actuallyWritten = 0;
		actuallyWritten = [self.outputStream write:buffer.bytes + offset
						 maxLength:bufferLength];
		offset += actuallyWritten;

		if ((offset >= bufferLength))
		{
			[self.writeArray removeObjectAtIndex:0];
			bufferLength = 0;
			offset = 0;
		}
	}

	self.isWriting = NO;
}

#pragma mark - read methods

- (void) readMessage
{
	static uint8_t s_buffer[1024*8];
	static uint32_t s_currentMessageLefted  = 0;
	static uint32_t s_offset = 0;
	static NSMutableData *s_bufferData = nil;

	if (self.connectionRest)
	{
		s_currentMessageLefted = 0;
		[s_bufferData release];
		s_bufferData = nil;
		self.connectionRest = NO;
	}
	
	START_NETWORK_INDICATOR();

	int actuallyReaded = [self.inputStream read:s_buffer + s_offset
					  maxLength:sizeof(s_buffer) - s_offset];
	STOP_NETWORK_INDICATOR();

	if ( 0 > actuallyReaded)
	{
		LOG(@"Error read input stream error with %d", actuallyReaded);
	}

	while (0 < actuallyReaded)
	{
		if (0 == s_currentMessageLefted)
		{
			assert(nil == s_bufferData);

			if (HEADER_SIZE <= (actuallyReaded + s_offset))
			{
				// readed buffer is longer than header
				uint32_t header = CFSwapInt32BigToHost(*(uint32_t *)s_buffer);
				s_currentMessageLefted  = (header & HEADER_LENGTH_MASK) + HEADER_SIZE;
				s_bufferData = [[NSMutableData alloc] init];
				s_offset = 0;
			}
			else
			{
				// readed buffer is shorter than header
				s_offset += actuallyReaded;

				return;
			}
		}

		if (s_currentMessageLefted > actuallyReaded)
		{
			// message still not read complete
			[s_bufferData appendBytes:s_buffer length:actuallyReaded];
			s_currentMessageLefted -= actuallyReaded;
			actuallyReaded = 0;
		}
		else
		{
			// one message read complete, handle it
			[s_bufferData appendBytes:s_buffer length:s_currentMessageLefted];
			HANDLE_MESSAGE(s_bufferData);
			[s_bufferData release];
			s_bufferData = nil;

			// move the buffer left from tail to head if needed
			uint32_t bufferLeft  = actuallyReaded - s_currentMessageLefted;
			if (0 < bufferLeft)
			{
				memmove(s_buffer, (s_buffer + s_currentMessageLefted), bufferLeft);
			}

			actuallyReaded = bufferLeft;
			s_currentMessageLefted = 0;
		}
	}
}

#pragma mark class interface

+ (void) requestSendMessage:(NSData *)message
{
	[gs_shared_instance requestSendMessage:message];
}

@end
