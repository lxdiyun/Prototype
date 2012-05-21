//
//  Util_Macro.h
//  Prototype
//
//  Created by Adrian Lee on 5/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef Prototype_Util_Macro_h
#define Prototype_Util_Macro_h

#include <libgen.h>

// LOG
#ifdef DEBUG
#define LOG(format, ...) { NSLog(@"%s %s %d:", basename(__FILE__), (char *)_cmd, __LINE__); NSLog(format, ## __VA_ARGS__); }
#else
#define LOG(format, ...)
#endif

#ifdef DEBUG
#define CLOG(format, ...) { NSLog(@"%s %s %d:", basename(__FILE__), __func__, __LINE__); NSLog(format, ## __VA_ARGS__); }
#else
#define CLOG(format, ...)
#endif

// singleton
#if (!__has_feature(objc_arc))
#define ARC_SINGLETON \
- (id) retain \
{ \
return self; \
} \
- (unsigned) retainCount \
{ \
return UINT_MAX;  \
}\
\
- (oneway void) release \
{\
}\
- (id) autorelease \
{ \
return self; \
}
#else
#define ARC_SINGLETON
#endif

#define DEFINE_SINGLETON(CLASS_NAME) \
static CLASS_NAME *gs_shared_instance; \
+ (id) allocWithZone:(NSZone *)zone \
{ \
if ([CLASS_NAME class] == self) \
{ \
return [gs_shared_instance retain]; \
} \
else \
{ \
return [super allocWithZone:zone]; \
} \
} \
- (id) copyWithZone:(NSZone *)zone \
{ \
return self; \
} \
ARC_SINGLETON \
+ (void) initialize \
{ \
if (self == [CLASS_NAME class]) \
{ \
gs_shared_instance = [[super allocWithZone:nil] init]; \
} \
} \
+ (id) getInstnace \
{\
return gs_shared_instance; \
}

// custom xib objects
#define DEFINE_CUSTOM_XIB(CLASS_NAME) \
+ (CLASS_NAME *) loadInstanceFromNib \
{  \
	CLASS_NAME *result = nil;  \
	 \
	NSArray* elements = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([CLASS_NAME class])  \
							  owner:nil  \
							options:nil];  \
	 \
	for (id anObject in elements)  \
	{  \
		if ([anObject isKindOfClass:[CLASS_NAME class]])  \
		{  \
			result = anObject; \
			 \
			break; \
		}  \
	}  \
	 \
	return result;  \
} \
- (id) awakeAfterUsingCoder:(NSCoder*)aDecoder \
{ \
	BOOL theThingThatGotLoadedWasJustAPlaceholder = ([[self subviews] count] == 0); \
	 \
	if (theThingThatGotLoadedWasJustAPlaceholder) \
	{ \
		CLASS_NAME *xibInstance = [[CLASS_NAME loadInstanceFromNib] retain]; \
		 \
		if ([self respondsToSelector:@selector(resetupXIB:)]) \
		{ \
			[self performSelector:@selector(resetupXIB:) withObject:xibInstance]; \
		} \
		 \
		return xibInstance; \
	} \
	 \
	return self; \
}

#endif
