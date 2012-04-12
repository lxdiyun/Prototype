//
//  OutputStreamDelegate.h
//  Prototype
//
//  Created by Adrian Lee on 12/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OutputStream : NSObject <NSStreamDelegate>
{
	NSData *_data;
	NSOutputStream *_outputStream;
	uint32_t _dataWritedLength;
}

@property (retain) NSData *data;
@property (retain) NSOutputStream *outputStream;

@end
