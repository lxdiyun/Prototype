//
//  UIImage+.m
//  Prototype
//
//  Created by Adrian Lee on 1/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIImage+Scale.h"

#include <math.h>
static inline double radians (double degrees) {return degrees * M_PI / 180;}

@implementation UIImage (Scale)

- (BOOL) checkBeforeScale:(CGSize)targetSize
{
	UIImage* sourceImage = self; 
	CGFloat orginMAXLength = MAX(sourceImage.size.width, sourceImage.size.height);
	CGFloat orginMINLength = MIN(sourceImage.size.width, sourceImage.size.height);
	CGFloat targetMAXLength = MAX(targetSize.width, targetSize.height);
	CGFloat targetMINLength = MIN(targetSize.width, targetSize.height);
	
	if (targetMAXLength < orginMAXLength) 
	{
		return YES;
	}
	
	if (targetMINLength < orginMINLength)
	{
		return YES;
	}
	
	return NO;
}

- (UIImage *) imageByScalingToSize:(CGSize)targetSize
{

        UIImage* sourceImage = self; 
        CGFloat targetWidth = targetSize.width;
        CGFloat targetHeight =targetSize.height;
	CGFloat ratio = 1.0;
	
        CGImageRef imageRef = [sourceImage CGImage];
        CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
        CGColorSpaceRef colorSpaceInfo = CGImageGetColorSpace(imageRef);
	
        if (bitmapInfo == kCGImageAlphaNone) 
	{
                bitmapInfo = kCGImageAlphaNoneSkipLast;
        }
	
        CGContextRef bitmap;
	
        if (sourceImage.imageOrientation == UIImageOrientationUp || sourceImage.imageOrientation == UIImageOrientationDown) 
	{
		// image in horizontal

		if (targetWidth < targetHeight)
		{
			targetWidth = targetSize.height;
			targetHeight = targetSize.width;
		}

		ratio =  targetWidth / self.size.width;
		targetHeight = self.size.height * ratio;
		
                bitmap = CGBitmapContextCreate(NULL, targetWidth, targetHeight, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
        } 
	else 
	{
		// image in vertical
		if (targetWidth > targetHeight)
		{
			targetWidth = targetSize.height;
			targetHeight = targetSize.width;
		}

		ratio =  targetWidth / self.size.width;
		targetHeight = self.size.height * ratio;
		
                bitmap = CGBitmapContextCreate(NULL, targetWidth, targetHeight, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
        }       
	
        if (sourceImage.imageOrientation == UIImageOrientationLeft) 
	{
                CGContextRotateCTM (bitmap, radians(90));
                CGContextTranslateCTM (bitmap, 0, -targetHeight);
		
        } 
	else if (sourceImage.imageOrientation == UIImageOrientationRight) 
	{
                CGContextRotateCTM (bitmap, radians(-90));
                CGContextTranslateCTM (bitmap, -targetWidth, 0);
		
        } 
	else if (sourceImage.imageOrientation == UIImageOrientationUp) 
	{
                // NOTHING
        } 
	else if (sourceImage.imageOrientation == UIImageOrientationDown) 
	{
                CGContextTranslateCTM (bitmap, targetWidth, targetHeight);
                CGContextRotateCTM (bitmap, radians(-180.));
        }
	
        CGContextDrawImage(bitmap, CGRectMake(0, 0, targetWidth, targetHeight), imageRef);
        CGImageRef ref = CGBitmapContextCreateImage(bitmap);
        UIImage* newImage = [UIImage imageWithCGImage:ref];
	
        CGContextRelease(bitmap);
        CGImageRelease(ref);
	
        return newImage; 
}

- (UIImage *) reduceToSize:(CGSize)targetSize
{
	if (![self checkBeforeScale:targetSize])
	{
		// size small than target， not scale
		return self;
	}
	else
	{
		return [self imageByScalingToSize:targetSize];
	}
}

@end
