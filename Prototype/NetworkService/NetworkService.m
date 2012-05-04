//
//  NetworkService.m
//  Prototype
//
//  Created by Adrian Lee on 12/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.

#import "NetworkService.h"


#import "Util.h"
#import "LoginManager.h"
#import "Message.h"

const static NSUInteger NETWORK_TRY_RECONNECT_TIMES = 3;
const static NSTimeInterval NETWORK_RECONNCECT_INTERVAL = 5; // seconds

@interface NetworkService () <NSStreamDelegate, UIAlertViewDelegate>
{
	NSInputStream *_inputStream;
	NSOutputStream *_outputStream;
	UIAlertView *_alertView;
	
	BOOL _isWriting;
	BOOL _outputStreamRest;
	BOOL _inputStreamRest;
	NSUInteger _reconnectedTimes;
}

@property (strong) NSInputStream *inputStream;
@property (strong) NSOutputStream *outputStream;
@property (strong) UIAlertView *alertView;
@property (assign) BOOL isWriting;
@property (assign) BOOL outputStreamRest;
@property (assign) BOOL inputStreamRest;
@property (assign) NSUInteger reconnectedTimes;


// connection
- (void) connect;
- (void) closeStream;
- (void) connectionRest;
- (void) streamOpened:(NSStream *)theStream;

// write
- (void) writeMessage;

// read
- (void) readMessage;

// alter
- (void) showAlter;

@end

@implementation NetworkService

@synthesize inputStream = _inputStream;
@synthesize outputStream = _outputStream;
@synthesize alertView = _alertView;
@synthesize isWriting = _isWriting;
@synthesize outputStreamRest = _outputStreamRest;
@synthesize inputStreamRest = _inputStreamRest;
@synthesize reconnectedTimes = _reconnectedTimes;


#pragma mark - singleton

DEFINE_SINGLETON(NetworkService);

#pragma mark - life circle 

- (id) init
{
	self = [super init];
	
	if (nil != self)
	{
		// init data
		{
			self.isWriting = NO;
			self.reconnectedTimes = 0;
		}
		
		[self connect];
	}
	
	return self;
}

- (void) dealloc 
{
	
	[self closeStream];
	
	// release object
	self.inputStream = nil;
	self.outputStream = nil;
	self.alertView = nil;
	
	[super dealloc];
}

#pragma mark - UIAlertViewDelegate

- (void) showAlter
{
	@autoreleasepool 
	{
		if (nil == self.alertView)
		{
			UIAlertView *alert = [[[UIAlertView alloc]  init] autorelease];
			alert.delegate = self;
			alert.title = @"网络异常";
			alert.message = @"连接服务器失败";
			[alert addButtonWithTitle:@"离线模式"];
			[alert addButtonWithTitle:@"重试连接"];
			self.alertView = alert;
		}
		[self.alertView show];
	}
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (1 == buttonIndex)
	{
		self.reconnectedTimes = 0;
		[self connect];
	}
	
	
}

#pragma mark - connection

- (void) connect 
{
	[self closeStream];
	
	CFReadStreamRef readStream;
	CFWriteStreamRef writeStream;
	// TODO: replace the network host address
	CFStreamCreatePairWithSocketToHost(NULL, 
					   (CFStringRef)@"alpha.meishiwanjia.com", 
					   4040, 
//					   (CFStringRef)@"192.168.2.113",
//					   8080,
					   &readStream, 
					   &writeStream);
	self.inputStream = (NSInputStream *)readStream;
	self.outputStream = (NSOutputStream *)writeStream;
	
	CFRelease(readStream);
	CFRelease(writeStream);
	
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
	
	START_NETWORK_INDICATOR();
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

- (void) resetNetworkStatus
{
	self.inputStreamRest = YES;
	self.outputStreamRest = YES;
	
	STOP_PING();
	ROLLBACK_ALL_PENDING_MESSAGE();
	STOP_ALL_NETWORK_INDICATOR();
	
	++self.reconnectedTimes;
}

- (void) connectionRest
{	
	[self closeStream];
	[self resetNetworkStatus];

	++self.reconnectedTimes;
	
	LOG(@"Error: network reconnected, time = %u", self.reconnectedTimes);
	
	if (NETWORK_TRY_RECONNECT_TIMES == self.reconnectedTimes)
	{
		[self showAlter];
	}
	else
	{
		// since we have two streams, we will receive reset twice, 
		// only connect once is needed
		if (1 == self.reconnectedTimes % 2)
		{
			[self performSelector:@selector(connect) 
				   withObject:nil 
				   afterDelay:NETWORK_RECONNCECT_INTERVAL];
		}
	}
}

- (void) streamOpened:(NSStream *)theStream
{
	if ([self.alertView isVisible])
	{
		[self.alertView dismissWithClickedButtonIndex:0 animated:YES];
	}
	self.reconnectedTimes = 0;

	if (theStream == self.outputStream)
	{
		STOP_NETWORK_INDICATOR();
		[LoginManager request];
	}
}

#pragma mark - NSStream delegate

- (void) stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent 
{
	// TODO remove comment to log
	switch (streamEvent) 
	{
		case NSStreamEventOpenCompleted:
			LOG(@"Stream opened");
			[self streamOpened:theStream];
			break;
			
		case NSStreamEventHasBytesAvailable:
			// LOG(@"Input Stream ready");
			[self readMessage];
			break;
			
		case NSStreamEventHasSpaceAvailable:
			// LOG(@"Ouput stream is ready");			
			// only 1000 time per time to write. will not block the ui event
			[self performSelector:@selector(writeMessage) withObject:nil afterDelay:0.001];
			break;
			
		case NSStreamEventErrorOccurred:
			LOG(@"Error Can not connect to the host!");
			[self connectionRest];
			break;
			
		case NSStreamEventEndEncountered:
			LOG(@"Error No buffer left to read!");
			[self connectionRest];
			break;
			
		default:
			LOG(@"Error Unknown event %i", streamEvent);
	}
}

#pragma mark - write methods

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
	
	static uint32_t s_offset;
	static uint32_t s_bufferLength = 0;
	static NSData *s_buffer;
	
	if (self.outputStreamRest)
	{
		s_offset = 0;
		s_bufferLength = 0;
		
		self.outputStreamRest = NO;
	}
	
	if (0 == s_bufferLength)
	{
		s_buffer = POP_BUFFER();
		
		if (nil == s_buffer)
		{
			// have no buffer to write, just reutun
			self.isWriting = NO;
			
			return;
		}
		
		s_bufferLength = s_buffer.length;
		s_offset = 0;
	}
	
	if (0 < s_bufferLength)
	{
		uint32_t actuallyWritten = 0;
		actuallyWritten = [self.outputStream write:s_buffer.bytes + s_offset
						 maxLength:s_bufferLength];
		s_offset += actuallyWritten;
		
		if ((s_offset >= s_bufferLength))
		{
			s_bufferLength = 0;
			s_offset = 0;
		}
	}
	
	self.isWriting = NO;
}

#pragma mark - read methods

- (void) readMessage
{
	static uint8_t s_buffer[1024 * 8];
	static uint32_t s_currentMessageLefted  = 0;
	static uint32_t s_offset = 0;
	static NSMutableData *s_bufferData = nil;
	
	if (self.inputStreamRest)
	{
		s_currentMessageLefted = 0;
		[s_bufferData release];
		s_bufferData = nil;
		self.inputStreamRest = NO;
	}
	
	int actuallyReaded = [self.inputStream read:s_buffer + s_offset
					  maxLength:sizeof(s_buffer) - s_offset];
	
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

#pragma mark - class interface

- (void) requestSendMessage
{
	if ([self.outputStream hasSpaceAvailable])
	{
		[self writeMessage];
	}
}

+ (void) requestSendMessage
{
	[[self getInstnace] requestSendMessage];
}

+ (void) reconnect
{
	[[self getInstnace] closeStream];
	[[self getInstnace] resetNetworkStatus];
	[[self getInstnace] connect];
}

+ (void) stop
{
	[[self getInstnace] closeStream];
}

@end
