//
//  UIImageView+RoundImage.h
//  Canvas2.0 Prototype
//
//  Created by Jason Larsen on 2/5/13.
//  Copyright (c) 2013 Jason Larsen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Circular)
- (void)makeViewCircular; // warning this will adjust your frame if it's not already rectangular
- (void)makeViewRectangular;
@end
