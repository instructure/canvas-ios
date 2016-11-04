
//
// Copyright (C) 2016-present Instructure, Inc.
//   
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
