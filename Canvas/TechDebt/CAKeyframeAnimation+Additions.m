//
//  CAKeyframeAnimation+Additions.m
//  iCanvas
//
//  Created by Rick Roberts on 9/19/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CAKeyframeAnimation+Additions.h"

@implementation CAKeyframeAnimation (Additions)

// Animations are calling fromValue on CAKeyFrameAnimation which is causing a crash
// We should identify the issue but this is fixng the crash for now
- (id)fromValue
{
    return nil;
}

@end
