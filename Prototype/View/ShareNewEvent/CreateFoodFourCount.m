//
//  CreateFoodFourCount.m
//  Prototype
//
//  Created by Adrian Lee on 1/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CreateFoodFourCount.h"

#import "Util.h"

typedef enum FOUR_COUNT_ENUM
{
	TASTY 	= 0x0,
	SPECIAL = 0x1,
	VALUED 	= 0x2,
	HEALTHY = 0x3,
	FOUR_COUNT_MAX

} FOUR_COUNT;

const static CGFloat FONT_SIZE = 15.0;
const static CGFloat LABEL_HEIGHT = 10.0;
const static CGFloat LABEL_WIDTH = 25.0;
const static CGFloat PADING1 = 10.0; // padding from left cell border
const static CGFloat PADING2 = 5.0; // padding between element horizontal and from right boder

static UIButton *gs_four_count_button[FOUR_COUNT_MAX] = {nil};
static UIColor *gs_four_count_color[FOUR_COUNT_MAX] = {nil};
static BOOL gs_four_count_selected_flag[FOUR_COUNT_MAX] = {NO};
static UILabel *gs_four_count_color_label[FOUR_COUNT_MAX] = {nil};
static UILabel *gs_four_count_text_label[FOUR_COUNT_MAX] = {nil};
static NSString *gs_four_count_text[FOUR_COUNT_MAX] = {@"美味", @"特色", @"超值", @"健康"};
static UILabel *gs_star_label = nil;

@implementation CreateFoodFourCount

@synthesize delegate = _delegate;

#pragma mark - UI

- (void)drawRect:(CGRect)rect
{
	CGFloat buttonWidth = rect.size.width / 4;
	CGFloat x = 0.0;

	for (int i = 0; i < FOUR_COUNT_MAX; ++i) 
	{
		if (nil != gs_four_count_color_label[i])
		{
			[gs_four_count_color_label[i] removeFromSuperview];
			[gs_four_count_color_label[i] release];
		}
		
		if (nil != gs_four_count_text_label[i])
		{
			[gs_four_count_text_label[i] removeFromSuperview];
			[gs_four_count_text_label[i] release];
		}

		if (nil != gs_four_count_button[i])
		{
			[gs_four_count_button[i] removeFromSuperview];
			[gs_four_count_button[i] release];
		}
		
		// clean flag
		gs_four_count_selected_flag[i] = NO;

		// setup button
		gs_four_count_button[i] = [[UIButton alloc] initWithFrame:CGRectMake(x, 
										     0.0, 
										     buttonWidth, 
										     rect.size.height)];
		[gs_four_count_button[i] addTarget:self action:@selector(buttonChicked:) forControlEvents:UIControlEventTouchUpInside];
		gs_four_count_button[i].backgroundColor = [Color milkColor];
		
		// setup color label
		CGFloat colorX = PADING1 * PROPORTION();
		gs_four_count_color_label[i] = [[UILabel alloc] initWithFrame:CGRectMake(colorX, 
											0.0, 
											LABEL_WIDTH * PROPORTION(),
											LABEL_HEIGHT * PROPORTION())];
		[gs_four_count_button[i] addSubview:gs_four_count_color_label[i]];
		gs_four_count_color_label[i].center = CGPointMake(gs_four_count_color_label[i].center.x, rect.size.height / 2);
		gs_four_count_color_label[i].backgroundColor = [Color grey2Color];
		
		// setup text label
		CGFloat textX = (LABEL_WIDTH + PADING2) * PROPORTION() + colorX;
		gs_four_count_text_label[i] = [[UILabel alloc] initWithFrame:CGRectMake(textX, 
										       0.0, 
										       buttonWidth - textX,
										       FONT_SIZE * PROPORTION())];
		[gs_four_count_button[i] addSubview:gs_four_count_text_label[i]];
		gs_four_count_text_label[i].center = CGPointMake(gs_four_count_text_label[i].center.x, rect.size.height / 2);
		gs_four_count_text_label[i].text = gs_four_count_text[i];
		gs_four_count_text_label[i].font = [UIFont systemFontOfSize:FONT_SIZE];
		gs_four_count_text_label[i].backgroundColor = [UIColor clearColor];

		[self addSubview:gs_four_count_button[i]];
		x += buttonWidth;
	}
	
	gs_star_label =[[[UILabel alloc] initWithFrame:CGRectMake(5.0, 0.0, FONT_SIZE * PROPORTION(), FONT_SIZE * PROPORTION())] autorelease];
	gs_star_label.text = @"*";
	gs_star_label.backgroundColor = [UIColor clearColor];
	gs_star_label.textColor = [UIColor redColor];
	gs_star_label.font = [UIFont boldSystemFontOfSize:FONT_SIZE * PROPORTION()];
	
	[self addSubview:gs_star_label];
	
	self.backgroundColor = [Color milkColor];
}

#pragma mark - lifecircle

- (void) setupColor
{
	gs_four_count_color[TASTY] = [[Color tastyColor] retain];
	gs_four_count_color[SPECIAL] = [[Color specailColor] retain];
	gs_four_count_color[VALUED] = [[Color valuedColor] retain];
	gs_four_count_color[HEALTHY] = [[Color healthyColor] retain];
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (nil != self) 
	{
		[self setupColor];
	}
	return self;
}

-(void) dealloc
{
	for (int i = 0; i < FOUR_COUNT_MAX; ++i) 
	{
		[gs_four_count_button[i] removeFromSuperview];
		[gs_four_count_button[i] release];
		gs_four_count_button[i] = nil;
		
		[gs_four_count_color[i] release];
		gs_four_count_color[i] = nil;
	}
	
	[gs_star_label release];
	gs_star_label = nil;

	[super dealloc];
}

#pragma mark - actin and interface

-(void) buttonChicked:(UIButton *)sender
{
	for (int i = 0; i < FOUR_COUNT_MAX; ++i) 
	{
		if (gs_four_count_button[i] == sender)
		{
			if (YES == gs_four_count_selected_flag[i])
			{
				gs_four_count_color_label[i].backgroundColor = [Color grey2Color];
				gs_four_count_selected_flag[i] = NO;
			}
			else
			{
				gs_four_count_color_label[i].backgroundColor = gs_four_count_color[i];
				gs_four_count_selected_flag[i] = YES;
			}
			
			[self.delegate fourCountSelected];
			return;
		}
	}
}

- (BOOL) isFourCountSelected
{
	for (int i = 0; i < FOUR_COUNT_MAX; ++i)
	{
		if (YES == gs_four_count_selected_flag[i])
		{
			gs_star_label.textColor = [UIColor clearColor];
			return YES;
		}
	}
	
	gs_star_label.textColor = [UIColor redColor];
	return NO;
}

- (void) setFoutCountParams:(NSMutableDictionary *)params
{
	[params setValue:[NSNumber numberWithBool:gs_four_count_selected_flag[SPECIAL]]  forKey:@"like_special"];
	[params setValue:[NSNumber numberWithBool:gs_four_count_selected_flag[VALUED]]  forKey:@"like_valued"];
	[params setValue:[NSNumber numberWithBool:gs_four_count_selected_flag[TASTY]]  forKey:@"like_tasty"];
	[params setValue:[NSNumber numberWithBool:gs_four_count_selected_flag[HEALTHY]]  forKey:@"like_healthy"];
}

- (void) cleanFourCount
{
	for (int i = 0; i < FOUR_COUNT_MAX; ++i) 
	{
		gs_four_count_selected_flag[i] = NO;
		gs_four_count_color_label[i].backgroundColor = [Color grey2Color];
		gs_star_label.textColor = [UIColor redColor];
	}
}


@end
