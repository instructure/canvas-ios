//
//  UIFont+Canvas.m
//  iCanvas
//
//  Created by Jason Larsen on 6/12/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "UIFont+Canvas.h"

@implementation UIFont (Canvas)

#pragma mark - Font Generators

+ (UIFont *)canvasFontOfSize:(CGFloat)size {
    return [UIFont fontWithName:@"HelveticaNeue" size:size];
}

+ (UIFont *)boldCanvasFontOfSize:(CGFloat)size {
    return [UIFont fontWithName:@"HelveticaNeue-Bold" size:size];
}

+ (UIFont *)italicCanvasFontOfSize:(CGFloat)size{
    return [UIFont fontWithName:@"HelveticaNeue-Italic" size:size];
}

#pragma mark - Predefined Fonts

+ (UIFont *)canvasHeaderFont {
    return [UIFont canvasFontOfSize:18.0f];
}

+ (UIFont *)canvasHeader2Font {
    return [UIFont canvasFontOfSize:13.0f];
}

+ (UIFont *)canvasHeader2BoldFont {
    return [UIFont boldCanvasFontOfSize:13.0f];
}

+ (UIFont *)canvasSubHeaderFont {
    return [UIFont boldCanvasFontOfSize:11.0f];
}

+ (UIFont *)canvasFont {
    return [UIFont canvasFontOfSize:11.0f];
}

+ (UIFont *)canvasSmallFont {
    return [UIFont canvasFontOfSize:9.0f];
}

@end
