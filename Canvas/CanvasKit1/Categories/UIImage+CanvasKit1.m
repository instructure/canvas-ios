//
//  UIImage+CanvasKit1.m
//  Canvas
//
//  Created by Ben Kraus on 8/5/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

#import "UIImage+CanvasKit1.h"
#import "CKModelObject.h"

@implementation UIImage (CanvasKit1)
+ (instancetype)canvasKit1ImageNamed:(NSString *)name {
    static NSBundle *canvasKit1Bundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        canvasKit1Bundle = [NSBundle bundleForClass:[CKModelObject class]];
    });
    return [self imageNamed:name inBundle:canvasKit1Bundle compatibleWithTraitCollection:nil];
}

@end
