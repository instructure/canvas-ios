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

#import "CBIQuizViewModel.h"

@implementation CBIQuizViewModel

@dynamic model;

- (instancetype)init
{
    self = [super init];
    if (self) {
        RAC(self, name) = RACObserve(self, model.title);
        RAC(self, dueAt) = RACObserve(self, model.dueAt);
        RAC(self, subtitle) = [RACObserve(self, model.dueAt) map:^id(NSDate *date) {
            static  NSDateFormatter *dateFormatter;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                dateFormatter = [[NSDateFormatter alloc] init];
                dateFormatter.dateStyle = NSDateFormatterLongStyle;
            });
            return [dateFormatter stringFromDate:date];
        }];
    }
    return self;
}



@end
