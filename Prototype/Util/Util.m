//
//  Util.m
//  Prototype
//
//  Created by Adrian Lee on 12/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Util.h"

#import "SBJson.h"

#import "NetworkService.h"

@implementation Util
@end

uint32_t GET_MSG_ID(void)
{
	const static uint32_t INIT_ID = 0x10;
	const static uint32_t MAX_ID = 0xFFFF;
	const static NSString *lock = @"GET_MSG_ID";
	static uint32_t s_id_count = INIT_ID;
	
	@synchronized(lock) 
	{
		uint32_t returnID = ++s_id_count;
		
		if (MAX_ID <= s_id_count)
		{
			s_id_count = INIT_ID;
		}
		
		return returnID;
	}
}

static void convert_dictonary_to_json_data(NSDictionary *input_dict, NSMutableData * output_data)
{
	@autoreleasepool 
	{
		NSData *data = [input_dict JSONDataRepresentation];
		uint32_t header;
		
		if (nil != data)
		{
			header = CFSwapInt32HostToBig(data.length) | (JSON_MSG << HEADER_LENGTH_BITS);
		}
		
		if (nil !=output_data)
		{
			[output_data appendBytes:(void*)&header length:HEADER_SIZE];
			[output_data appendData: data];
		}
	}			
}

static void convert_msg_dictonary_to_data(NSDictionary *input_dict, NSMutableData * output_data)
{	
	convert_dictonary_to_json_data(input_dict, output_data);
}

void SEND_MSG_AND_BIND_HANDLER(NSDictionary *messageDict, id target, SEL handler, uint32_t ID)
{
	NSMutableData *data = [[NSMutableData alloc] init];

	convert_msg_dictonary_to_data(messageDict, data);

	SEND_AND_BIND_HANDLER(data, target, handler, ID);

	[data release];

}

void MANAGE_OBJ(id<HJMOUser> managedImage)
{
	static HJObjManager *s_objMan = nil;
	
	if (nil == s_objMan)
	{
		s_objMan = [[HJObjManager alloc] initWithLoadingBufferSize:10 memCacheSize:20];
		NSString* cacheDirectory = [NSHomeDirectory() stringByAppendingString:@"/Library/Caches/imgcache"];
		HJMOFileCache* fileCache = [[HJMOFileCache alloc] initWithRootPath:cacheDirectory];
		
		s_objMan.fileCache = fileCache;
		
		[fileCache release];
	}
	
	[s_objMan manage:managedImage];
}


