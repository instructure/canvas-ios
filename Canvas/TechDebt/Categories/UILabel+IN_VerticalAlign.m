//
//  UILabel+IN_VerticalAlign.m
//  iCanvas
//
//  Created by Mark Suman on 10/18/11.
//  Copyright (c) 2011 Instructure. All rights reserved.
//

#import "UILabel+IN_VerticalAlign.h"

@implementation UILabel (IN_VerticalAlign)

- (void)alignTop
{
    // Code snippet borrowed from a SO answer on vertial alignment of a UILabel
    CGSize fontSize = [self.text sizeWithAttributes:@{NSFontAttributeName: self.font}];
    double finalHeight = fontSize.height * self.numberOfLines;
    double finalWidth = self.frame.size.width;
    CGRect rect = [self.text boundingRectWithSize:CGSizeMake(finalWidth, finalHeight) options:NSStringDrawingUsesDeviceMetrics attributes:@{NSFontAttributeName:self.font} context:nil];
    CGSize theStringSize = rect.size;
    int newLinesToPad = (finalHeight  - theStringSize.height) / fontSize.height;
    for(int i=0; i<newLinesToPad; i++)
        self.text = [self.text stringByAppendingString:@"\n "];
}

@end
