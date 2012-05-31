//
//  Color.m
//  Prototype
//
//  Created by Adrian Lee on 5/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Color.h"

@implementation Color

+ (UIColor *) tasty
{
	static UIColor *color = nil;
	
	if (nil == color)
	{
		color = [[UIColor alloc] initWithRed:0x21/255.0 green:0xA6/255.0 blue:0xCE/255.0 alpha:1.0];
	}
	
	return color;
}

+ (UIColor *) specail
{
	static UIColor *color = nil;
	
	if (nil == color)
	{
		color = [[UIColor alloc] initWithRed:0xDD/255.0 green:0x4B/255.0 blue:0x39/255.0 alpha:1.0];
	}
	
	return color;
}

+ (UIColor *) valued
{
	static UIColor *color = nil;
	
	if (nil == color)
	{
		color = [[UIColor alloc] initWithRed:0xFB/255.0 green:0xB0/255.0 blue:0x3B/255.0 alpha:1.0];
	}
	
	return color;
}

+ (UIColor *) healthy
{
	static UIColor *color = nil;
	
	if (nil == color)
	{
		color = [[UIColor alloc] initWithRed:0x6A/255.0 green:0xC6/255.0 blue:0x00/255.0 alpha:1.0];
	}
	
	return color;
}

+ (UIColor *) milk
{
	static UIColor *color = nil;
	
	if (nil == color)
	{
		color = [[UIColor alloc] initWithRed:0xE6/255.0 green:0xE6/255.0 blue:0xE6/255.0 alpha:1.0];
	}
	
	return color;
}

+ (UIColor *) orange
{
	static UIColor *color = nil;
	
	if (nil == color)
	{
		color = [[UIColor alloc] initWithRed:0xD3/255.0 green:0x8E/255.0 blue:0x33/255.0 alpha:1.0];
	}
	
	return color;
}

+ (UIColor *) grey1
{
	static UIColor *color = nil;
	
	if (nil == color)
	{
		color = [[UIColor alloc] initWithRed:0xEE/255.0 green:0xEE/255.0 blue:0xEE/255.0 alpha:1.0];
	}
	
	return color;
}

+ (UIColor *) grey2
{
	static UIColor *color = nil;
	
	if (nil == color)
	{
		
		color = [[UIColor alloc] initWithRed:0x66/255.0 green:0x66/255.0 blue:0x66/255.0 alpha:1.0];
	}
	return color;
}

+ (UIColor *) grey3
{
	static UIColor *color = nil;
	
	if (nil == color)
	{
		color = [[UIColor alloc] initWithRed:0x4D/255.0 green:0x4D/255.0 blue:0x4D/255.0 alpha:1.0];
	}
	
	return color;
}

+ (UIColor *) darkgrey
{
	static UIColor *color = nil;
	
	if (nil == color)
	{
		color = [[UIColor alloc] initWithRed:0x32/255.0 green:0x32/255.0 blue:0x32/255.0 alpha:1.0];
	}
	
	return color;
}

+ (UIColor *) brown
{
	static UIColor *color = nil;
	
	if (nil == color)
	{
		color = [[UIColor alloc] initWithRed:0x40/255.0 green:0x24/255.0 blue:0x1A/255.0 alpha:1.0];
	}
	
	return color;
}

+ (UIColor *) blackAlpha50
{
	static UIColor *color = nil;
	
	if (nil == color)
	{
		color = [[UIColor alloc] initWithRed:0x0/255.0 green:0x0/255.0 blue:0x0/255.0 alpha:0.5];
	}
	
	return color;
}

+ (UIColor *) blackAlpha75
{
	static UIColor *color = nil;
	
	if (nil == color)
	{
		color = [[UIColor alloc] initWithRed:0x0/255.0 green:0x0/255.0 blue:0x0/255.0 alpha:0.75];
	}
	
	return color;
}

+ (UIColor *) blackAlpha85
{
	static UIColor *color = nil;
	
	if (nil == color)
	{
		color = [[UIColor alloc] initWithRed:0x0/255.0 green:0x0/255.0 blue:0x0/255.0 alpha:0.85];
	}
	
	return color;
}

+ (UIColor *) whiteAlpha50
{
	static UIColor *color = nil;
	
	if (nil == color)
	{
		color = [[UIColor alloc] initWithRed:0xFF/255.0 green:0xFF/255.0 blue:0xFF/255.0 alpha:0.5];
	}
	
	return color;
}

+ (UIColor *) lightyellow 
{
	static UIColor *color = nil;
	
	if (nil == color)
	{
		color = [[UIColor alloc] initWithRed:0xEF/255.0 green:0xDD/255.0 blue:0xAC/255.0 alpha:1.0];
	}
	
	return color;
}

+ (UIColor *) darkyellow 
{
	static UIColor *color = nil;
	
	if (nil == color)
	{
		color = [[UIColor alloc] initWithRed:0xD8/255.0 green:0xC5/255.0 blue:0x9A/255.0 alpha:1.0];
	}
	
	return color;
}

+ (UIColor *) blue
{
	static UIColor *color = nil;
	
	if (nil == color)
	{
		color = [[UIColor alloc] initWithRed:0x4B/255.0 green:0x92/255.0 blue:0x99/255.0 alpha:1.0];
	}
	
	return color;
}

@end

