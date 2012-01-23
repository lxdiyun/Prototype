//
//  UIImage+.m
//  Prototype
//
//  Created by Adrian Lee on 1/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIImage+Scale.h"

#include <math.h>
static inline double radians (double degrees) {return degrees * M_PI/180;}

@implementation UIImage (Scale)

- (BOOL) checkBeforeScale:(CGSize)targetSize
{
	UIImage* sourceImage = self; 
	CGSize size = sourceImage.size;
	
	if (sourceImage.imageOrientation == UIImageOrientationUp || 
	    sourceImage.imageOrientation == UIImageOrientationDown)
	{
		if ((size.width > targetSize.width) || (size.height > targetSize.height))
		{
			return YES;
		}
		else
		{
			return NO;
		}
	}
	else if (sourceImage.imageOrientation == UIImageOrientationLeft || 
		 sourceImage.imageOrientation == UIImageOrientationRight)
	{
		if ((size.width > targetSize.height) || (size.height > targetSize.width))
		{
			return YES;
		}
		else
		{
			return NO;
		}
	}
	
	return YES;
}

- (UIImage *) imageByScalingToSize:(CGSize)targetSize
{

        UIImage* sourceImage = self; 
        CGFloat targetWidth = targetSize.width;
        CGFloat targetHeight = 0.0;
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
		ratio =  targetWidth / self.size.width;
		targetHeight = self.size.height * ratio;
                bitmap = CGBitmapContextCreate(NULL, targetWidth, targetHeight, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
		
        } 
	else 
	{
		ratio =  targetWidth / self.size.height;
		targetHeight = self.size.width * ratio;
                bitmap = CGBitmapContextCreate(NULL, targetHeight, targetWidth, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
		
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
