//
//  AvatorCell.m
//  Prototype
//
//  Created by Adrian Lee on 12/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AvatorCell.h"

@interface AvatorCell () 
{
@private
	ImageV *_avatorImageV;
}

@end

@implementation AvatorCell
@synthesize avatorImageV = _avatorImageV;

- (void)setupAvatorImageV
{
	if (self)
	{
		@autoreleasepool 
		{
			if (nil == self.avatorImageV)
			{
				self.avatorImageV = [[ImageV alloc] 
						     initWithFrame:CGRectMake(70.0, 5.0, 50, 50)];
			}
			
			[self addSubview:self.avatorImageV];
		}
	}
}

- (void)dealloc 
{
    [self setAvatorImageV:nil];
    [super dealloc];
}
@end
