//
//  CBICalendarEventViewModel.m
//  iCanvas
//
//  Created by nlambson on 1/8/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CBICalendarEventViewModel.h"
#import <CanvasKit/CanvasKit.h>
#import "EXTScope.h"
#import "CBIColorfulViewModel+CellViewModel.h"
#import "UIImage+TechDebt.h"

@implementation CBICalendarEventViewModel

- (id)init
{
    self = [super init];
    if (self) {
        RAC(self, name) = RACObserve(self, model.title);
        RAC(self, syllabusDate) = RACObserve(self, model.startAt);
        RAC(self, subtitle) = [RACObserve(self, model.startAt) map:^id(NSDate *unformattedDueDate) {
            if (!unformattedDueDate) {
                return NSLocalizedString(@"No due date", @"String for when assignment has no due date");
            }
            static NSDateFormatter *formatter;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                formatter = [[NSDateFormatter alloc] init];
                formatter.dateStyle = NSDateFormatterShortStyle;
                formatter.timeStyle = NSDateFormatterShortStyle;
            });
            return [formatter stringFromDate:unformattedDueDate];
        }];
        self.icon = [[UIImage techDebtImageNamed:@"icon_calendar"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    return self;
}

- (CGFloat)tableViewController:(MLVCTableViewController *)controller heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

@end
