//
//  Util.h
//  Prototype
//
//  Created by Adrian Lee on 12/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#ifndef  _UTIL_H_
#define  _UTIL_H_

#ifdef DEBUG
#define LOG(format, ...) { NSLog(@"%s %s %d:", __FILE__, (char *)_cmd, __LINE__); NSLog(format, ## __VA_ARGS__); }
#else
#define LOG(format, ...)
#endif

#ifdef DEBUG
#define CLOG(format, ...) { NSLog(@"%s %s %d:", __FILE__, __func__, __LINE__); NSLog(format, ## __VA_ARGS__); }
#else
#define CLOG(format, ...)
#endif

#import <Foundation/Foundation.h>

void SEND_MSG_AND_BIND_HANDLER(NSDictionary *messageDict, id target, SEL handler);

#endif
