//
//  CBIQuizViewModel.m
//  iCanvas
//
//  Created by Derrick Hathaway on 3/19/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CBIQuizViewModel.h"

@implementation CBIQuizViewModel

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
