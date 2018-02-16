//
//  NSLayoutConstraintHairline.m
//  CanvasKeymaster
//
//  Created by Layne Moseley on 2/14/18.
//  Copyright © 2018 Instructure. All rights reserved.
//

#import "NSLayoutConstraintHairline.h"

@implementation NSLayoutConstraintHairline

- (void)awakeFromNib {
    [super awakeFromNib];
    self.constant = 1.0/[UIScreen mainScreen].scale;
}

@end
