//
//  UIImage+Blur.m
//  iCanvas
//
//  Created by derrick on 4/30/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "UIImage+Blur.h"

@implementation UIImage (Blur)

- (UIImage *)imageBlurredWithRadius:(CGFloat)blurRadius
{
    CIImage *inputImage = [CIImage imageWithCGImage:self.CGImage];
    CIFilter *blurFilter = [CIFilter filterWithName:@"CIGaussianBlur" keysAndValues:@"inputRadius", @(blurRadius), @"inputImage", inputImage, nil];
    CIFilter *darkenFilter = [CIFilter filterWithName:@"CIExposureAdjust" keysAndValues:@"inputEV", @(-1.3), @"inputImage", blurFilter.outputImage, nil];
    CIImage *outputImage = [darkenFilter outputImage];
    CIContext *context = [CIContext contextWithOptions:nil];
    
    return [[UIImage alloc] initWithCGImage:[context createCGImage:outputImage fromRect:outputImage.extent] scale:self.scale orientation:self.imageOrientation];
}

@end
