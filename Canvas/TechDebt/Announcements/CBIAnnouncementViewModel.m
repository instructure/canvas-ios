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
    
    

#import "CBIAnnouncementViewModel.h"
#import <CanvasKit/CanvasKit.h>
#import "EXTScope.h"

@implementation CBIAnnouncementViewModel
@synthesize model=_model, index=_index, position;

- (id)init
{
    self = [super init];
    if (self) {
        RAC(self, name) = RACObserve(self, model.title);
        RAC(self, viewControllerTitle) = RACObserve(self, model.title);
        RAC(self, date) = RACObserve(self, model.postedAt);
        RAC(self, subtitle) = [RACObserve(self, date) map:^(NSDate * value) {
            static NSDateFormatter *formatter;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                formatter = [[NSDateFormatter alloc] init];
                formatter.dateStyle = NSDateFormatterShortStyle;
                formatter.timeStyle = NSDateFormatterShortStyle;
            });
            if (value == nil) {
                return @"";
            }
            return [formatter stringFromDate:value];
        }];
        self.icon = nil;
    }
    return self;
}

@end

