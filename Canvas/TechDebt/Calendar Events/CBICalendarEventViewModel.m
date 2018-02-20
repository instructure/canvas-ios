//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
