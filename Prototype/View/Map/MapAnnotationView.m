//
//  MapAnnotationView.m
//  Prototype
//
//  Created by Adrian Lee on 4/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MapAnnotationView.h"

#import <QuartzCore/QuartzCore.h>

#import "Util.h"
#import "MapAnnotation.h"

// half the image's size in pixel
const static CGFloat IMAGE_OFFSET_X = 1;
const static CGFloat IMAGE_OFFSET_Y = -13;
const static CGPoint IMAGE_OFFSET = {IMAGE_OFFSET_X, IMAGE_OFFSET_Y};
const static CGPoint SCORE_CENTER = {13,13};
const static CGFloat SCORE_FONT_SIZE = 12;

@interface MapAnnotationView ()
{
	BOOL _selected;
	UILabel *_score;
	UITapGestureRecognizer* _tapRecognizer;
}

@property (assign) BOOL selected;
@property (retain) UITapGestureRecognizer* tapRecognizer;
@property (retain) UILabel *score;

@end

@implementation MapAnnotationView

@synthesize delegate;
@synthesize selected = _selected;
@synthesize tapRecognizer = _tapRecognizer;
@synthesize score = _score;

- (void) updateScore
{
	@autoreleasepool 
	{
		double score = [[[(MapAnnotation *)self.annotation placeObject] valueForKey:@"taste_score"] doubleValue];
		
		if (0 < score)
		{
			self.score.text = GET_STRING_FOR_SCORE(score);
			
			[self.score sizeToFit];
			self.score.center = SCORE_CENTER;
			self.score.backgroundColor = [UIColor whiteColor];
		}
		else
		{
			self.score.backgroundColor = [UIColor clearColor];
			self.score.text = @"";
		}
	}
}

- (id) initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];

	if (self) 
	{
		@autoreleasepool 
		{
			self.image = [UIImage imageNamed:@"place.png"];
			self.centerOffset = IMAGE_OFFSET;
			self.selected = NO;
			
			self.score = [[[UILabel alloc] init] autorelease];
			self.score.textColor = [UIColor blackColor];
			self.score.font = [UIFont systemFontOfSize:SCORE_FONT_SIZE];
			self.score.layer.cornerRadius = 6.0f;
			[self addSubview:self.score];
			[self updateScore];
			
			// gesture
			UITapGestureRecognizer* tap = [[[UITapGestureRecognizer alloc] init] autorelease];
			[tap addTarget:self action:@selector(tapHandler:)];
			self.tapRecognizer = tap;
		}

	}
	return self;
}

- (void) dealloc
{
	self.delegate = nil;
	self.tapRecognizer = nil;
	self.score = nil;

	[super dealloc];
}

- (void) markSelected
{
	self.image = [UIImage imageNamed:@"selected_place.png"];
	self.centerOffset = IMAGE_OFFSET;
	self.selected = YES;

	[self addGestureRecognizer:self.tapRecognizer];
}

- (void) markUnSelected
{
	self.image = [UIImage imageNamed:@"place.png"];
	self.centerOffset = IMAGE_OFFSET;
	self.selected = NO;

	[self removeGestureRecognizer:self.tapRecognizer];
}

- (void) tapHandler:(UITapGestureRecognizer *)recognizer
{
	if (YES == self.selected)
	{
		[self.delegate retap:self];
	}
}

- (void) setAnnotation:(id<MKAnnotation>)annotation
{
	[super setAnnotation:annotation];
	
	[self updateScore];
}

@end
