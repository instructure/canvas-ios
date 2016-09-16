//
//  CBISyllabusViewModel.m
//  iCanvas
//
//  Created by nlambson on 1/8/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CBISyllabusViewModel.h"
#import <CanvasKit/CanvasKit.h>
#import "EXTScope.h"
#import "UIImage+TechDebt.h"

@implementation CBISyllabusViewModel
- (UIImage *)imageForTypeName:(NSString *)typeString
{
    return [[UIImage techDebtImageNamed:@"icon_syllabus"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.name = NSLocalizedString(@"Syllabus", @"Title for Syllabus view controller");
        self.icon = [self imageForTypeName:nil];
        self.syllabusDate = [NSDate date];
        self.viewControllerTitle = self.name;
    }
    return self;
}

@end
