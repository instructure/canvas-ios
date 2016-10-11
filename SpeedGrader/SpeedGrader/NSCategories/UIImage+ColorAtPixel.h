//
//  UIImage+ColorAtPixel.h
//  SpeedGrader
//
//  Created by Brandon Pluim on 9/12/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ColorAtPixel)

- (UIColor *)colorAtPixel:(CGPoint)point;

@end
