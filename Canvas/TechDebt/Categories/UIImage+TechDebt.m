//
//  UIImage+TechDebt.m
//  Canvas
//
//  Created by Derrick Hathaway on 5/27/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

#import "UIImage+TechDebt.h"
#import "CBIViewModel.h"

@implementation UIImage (TechDebt)
+ (instancetype)techDebtImageNamed:(NSString *)name {
    static NSBundle *techDebtBundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        techDebtBundle = [NSBundle bundleForClass:[CBIViewModel class]];
    });
    return [self imageNamed:name inBundle:techDebtBundle compatibleWithTraitCollection:nil];
}
@end
