//
//  UIWebView+RemoveShadow.m
//  iCanvas
//
//  Created by Jason Larsen on 8/3/12.
//  Copyright (c) 2012 Instructure. All rights reserved.
//

#import "UIWebView+RemoveShadow.h"

@implementation UIWebView (RemoveShadow)

- (void)removeShadow {
    for(UIView *wview in [(self.subviews)[0] subviews]) {
        if([wview isKindOfClass:[UIImageView class]]) {
            wview.hidden  = YES;
        }
    }
}

@end
