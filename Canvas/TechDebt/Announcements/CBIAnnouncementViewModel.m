//
//  CBIAnnouncementViewModel.m
//  iCanvas
//
//  Created by nlambson on 1/2/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
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

