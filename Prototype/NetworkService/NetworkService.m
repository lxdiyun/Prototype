//
//  NetworkService.m
//  Prototype
//
//  Created by Adrian Lee on 12/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.

#import "NetworkService.h"

#import "SBJson.h"

#import "Util.h"

@interface NetworkService: NSObject <NSStreamDelegate>
{
	NSInputStream *_inputStream;
	NSOutputStream *_outputStream;
	NSMutableArray *_wrtieArray;
	NSMutableDictionary *_handlerDict;

	BOOL _isWriting;
	BOOL _connectionRest;
	SEL _reservedMsgHanlder[MAX_RESERVED_MSG];
}

@property (retain) NSInputStream *inputStream;
@property (retain) NSOutputStream *outputStream;
@property (retain) NSMutableArray *writeArray;
@property (retain) NSMutableDictionary *handlerDict;
@property (assign) BOOL isWriting;
@property (assign) BOOL connectionRest;

// initialization
- (void) setup;
- (void) connect;
- (void) closeStream;

// write
- (void) writeMessage;
- (void) requestSendMessage:(NSData *)message;

// read

- (void) readMessage;
- (void) handleMessage:(NSData *)bufferData;
- (void) addMessageHanlder:(SEL)handler withTarget:(id)targer withMessageID:(uint32_t)ID;

// reserved messages
- (void) setupReservedMessageHandler;
- (void) requestLogin;
- (void) loginMessageHandler:(id)dict;
- (void) requestPing;
- (void) jsonMessageHandler:(NSData *)bufferData;
- (void) pongMessageHandler:(NSData *)bufferData;

// singleton and interface
+ (NetworkService*) getInstance;
- (void) requestSendAndHandleMessage:(NSData *)message withTarget:(id)target withHandler:(SEL)hanlder withMessageID:(uint32_t)ID;

@end

@implementation NetworkService

@synthesize inputStream = _inputStream;
@synthesize outputStream = _outputStream;
@synthesize writeArray = _wrtieArray;
@synthesize handlerDict = _handlerDict;
@synthesize isWriting = _isWriting;
@synthesize connectionRest = _connectionRest;

#pragma mark -
#pragma mark Singleton Methods

static NetworkService *_sharedInstance = nil;

+ (void) initialize 
{
	if (self == [NetworkService class]) 
	{
		_sharedInstance = [[super allocWithZone:nil] init];
		[_sharedInstance setup];
	}
}

+ (NetworkService*) getInstance 
{
	return _sharedInstance;
}

+ (id) allocWithZone:(NSZone *)zone 
{
	return [[self getInstance] retain];
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
		[self setupReservedMessageHandler];
		NSMutableArray *tempArray = [[NSMutableArray alloc] init];
		self.writeArray = tempArray;
		[tempArray release];

		NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
		self.handlerDict = tempDict;
		[tempDict release];

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
	self.handlerDict = nil;

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

	[self.inputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] 
				    forMode:NSDefaultRunLoopMode];
	[self.outputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] 
				     forMode:NSDefaultRunLoopMode];
	[self.inputStream open];
	[self.outputStream open];
	
	self.connectionRest = YES;
	
	[self requestLogin];
}

- (void) closeStream
{
	if (nil != self.inputStream)
	{
		[self.inputStream close];
		[self.inputStream removeFromRunLoop:[NSRunLoop mainRunLoop] 
					    forMode:NSDefaultRunLoopMode];
		self.inputStream = nil;
	}
	if (nil != self.outputStream)
	{
		[self.outputStream close];
		[self.outputStream removeFromRunLoop:[NSRunLoop mainRunLoop] 
					     forMode:NSDefaultRunLoopMode];
		self.outputStream = nil;
	}
}

#pragma mark - NSstream delegate

- (void) stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
	NSLog(@"stream event %i", streamEvent);

	switch (streamEvent) 
	{
	case NSStreamEventOpenCompleted:
		NSLog(@"Stream opened");
		break;

	case NSStreamEventHasBytesAvailable:
		NSLog(@"Input Stream ready");
		[self readMessage];
		break;

	case NSStreamEventHasSpaceAvailable:
		NSLog(@"Ouput stream is ready");
		[self writeMessage];
		break;

	case NSStreamEventErrorOccurred:
		NSLog(@"Can not connect to the host!");
		[self connect];
		break;

	case NSStreamEventEndEncountered:
		NSLog(@"No buffer left to read!");
		[self connect];
		break;

	default:
		NSLog(@"Unknown event");
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
	
	int actuallyReaded = [self.inputStream read:s_buffer + s_offset
					       maxLength:sizeof(s_buffer) - s_offset];
	
	if ( 0 > actuallyReaded)
	{
		NSLog(@"Error read input stream error with %d", actuallyReaded);
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
			[self handleMessage:s_bufferData];
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

- (void) handleMessage:(NSData *)bufferData
{
	uint32_t header = CFSwapInt32HostToBig(*(uint32_t *)bufferData.bytes);
	
	uint32_t messageType = (header >> HEADER_LENGTH_BITS);
	
	if (MAX_RESERVED_MSG > messageType)
	{
		[self performSelector:_reservedMsgHanlder[messageType] withObject:bufferData];
	}
	else
	{
		NSLog(@"%@:%s:%d Error - recevied unknow message", [self class], (char *)_cmd, __LINE__);
	}
}

- (void) addMessageHanlder:(SEL)handler withTarget:(id)target withMessageID:(uint32_t)ID
{
	if (nil != handler)
	{
		NSMutableArray *targetAndHandler = [[NSMutableArray alloc] init];
		[targetAndHandler addObject:target];
		[targetAndHandler addObject:NSStringFromSelector(handler)];
		
		NSString *idString = [[NSString alloc] initWithFormat:@"%u", ID];
		
		[self.handlerDict setValue:targetAndHandler forKey:idString];

		[targetAndHandler release];
		[idString release];
	}
}

- (void) requestSendAndHandleMessage:(NSData*)message 
			 withTarget:(id)target
			withHandler:(SEL)hanlder 
		      withMessageID:(uint32_t)ID
{
	// add handler first
	[self addMessageHanlder:hanlder withTarget:target withMessageID:ID];

	// then send message
	[self requestSendMessage:message];
}

#pragma mark - reserved messages

- (void) setupReservedMessageHandler
{
	_reservedMsgHanlder[JSON_MSG] = @selector(jsonMessageHandler:);
	_reservedMsgHanlder[PING_PONG_MSG] = @selector(pongMessageHandler:);
	_reservedMsgHanlder[BINARY_MSG] = nil;
	_reservedMsgHanlder[GOOGLE_BUF_MSG] = nil;
}

- (void) jsonMessageHandler:(NSData *)bufferData
{
	uint32_t header = CFSwapInt32BigToHost(*(uint32_t *)bufferData.bytes);
	uint32_t messageLength  = header & HEADER_LENGTH_MASK;
	NSString *jsonString = [[NSString alloc] initWithBytes:(bufferData.bytes + HEADER_SIZE) 
							length:messageLength 
						      encoding:NSASCIIStringEncoding];	
	
	NSDictionary *messageDict = [jsonString JSONValue];
	
	[jsonString release];
	
	NSString *ID = [[messageDict objectForKey:@"id"] stringValue];
	NSArray *targetAndHandler = [self.handlerDict valueForKey:ID];
	
	// TODO: Remove
	// NSLog(@"ID = %@ message = %@ dict = \n%@", ID, messageDict, self.handlerDict);
	
	if (targetAndHandler)
	{
		[targetAndHandler retain];
		[self.handlerDict setValue:nil forKey:ID];
		
		id target = [targetAndHandler objectAtIndex:0];
		NSString *handlerString = [targetAndHandler objectAtIndex:1];
		SEL handler = NSSelectorFromString(handlerString);
		if ([target respondsToSelector:handler])
		{
			[target performSelector:handler withObject:messageDict];
		}
		
		[targetAndHandler release];
	}
}


- (void) requestPing
{
	uint32_t pingMessage = CFSwapInt32HostToBig(PING_PONG_MSG << HEADER_LENGTH_BITS);
	
	NSData *data = [[NSData alloc] initWithBytes:(void *)&pingMessage length:HEADER_SIZE];
	
	[self requestSendMessage:data];
	
	[data release];
}

- (void) pongMessageHandler:(NSData *)bufferData
{
	NSLog(@"Receive pong message!");
	[NSTimer scheduledTimerWithTimeInterval:50.0
					 target:self
				       selector:@selector(requestPing)
				       userInfo:nil
					repeats:NO];
}

- (void) requestLogin
{
	@autoreleasepool 
	{
		uint32_t messageID = GET_MSG_ID();
		NSMutableDictionary *params =  [[[NSMutableDictionary alloc] init] autorelease];
		NSMutableDictionary *request =  [[[NSMutableDictionary alloc] init] autorelease];
		
		// TODO update to real login user information
		[params setValue:@"wuvist" forKey:@"username"];
		[params setValue:@"dc6670b66d02cb02990e65272a936f36d25598d4" forKey:@"pwd"];
		
		[request setValue:@"sys.login" forKey:@"method"];
		[request setValue:params forKey:@"params"];
		[request setValue:[NSNumber numberWithUnsignedLong:messageID] forKey:@"id"];
		
		
		SEND_MSG_AND_BIND_HANDLER(request, self, @selector(loginMessageHandler:), messageID);
	}
}

- (void) loginMessageHandler:(id)dict
{
	NSLog(@"start ping");
	[self requestPing];
}


@end

void SEND_AND_BIND_HANDLER(NSData *message, id target, SEL handler, uint32_t ID)
{
	[[NetworkService getInstance] requestSendAndHandleMessage:message
						       withTarget:target
						      withHandler:handler
						    withMessageID:ID];
}
