//
//  CBIDiscussionTopicViewModel.m
//  iCanvas
//
//  Created by derrick on 12/18/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CBIDiscussionTopicViewModel.h"
#import "Router.h"
#import "ThreadedDiscussionViewController.h"
#import "CBIDiscussionTopicCell.h"

@implementation CBIDiscussionTopicViewModel
@synthesize model=_model, index=_index, position=_position;

- (id)init
{
    self = [super init];
    if (self) {
        RAC(self, name) = RACObserve(self, model.title);
        RAC(self, lockedItemName) = RACObserve(self, model.title);
        RAC(self, subtitle) = [RACObserve(self, model.lastReplyAt) map:^(NSDate * value) {
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
    }
    return self;
}

- (UITableViewCell *)tableViewController:(MLVCTableViewController *)controller cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CBIDiscussionTopicCell *cell = [controller.tableView dequeueReusableCellWithIdentifier:@"CBIDiscussionTopicCell"];
    cell.viewModel = self;
    return cell;
}

@end
