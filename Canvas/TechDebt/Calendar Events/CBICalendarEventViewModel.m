//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

#import "CBICalendarEventViewModel.h"
#import <CanvasKit/CanvasKit.h>
#import "EXTScope.h"
#import "CBIColorfulViewModel+CellViewModel.h"
#import "UIImage+TechDebt.h"

@implementation CBICalendarEventViewModel

@dynamic model;

- (id)init
{
    self = [super init];
    if (self) {
        RAC(self, name) = RACObserve(self, model.title);
        RAC(self, syllabusDate) = RACObserve(self, model.startAt);
        RAC(self, subtitle) = [RACObserve(self, model.startAt) map:^id(NSDate *unformattedDueDate) {
            if (!unformattedDueDate) {
                return NSLocalizedStringFromTableInBundle(@"No due date", nil, [NSBundle bundleForClass:self.class], @"String for when assignment has no due date");
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
