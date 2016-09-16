//
//  DiscussionEntryHeightCalculationOperation.m
//  iCanvas
//
//  Created by Derrick Hathaway on 4/28/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "DiscussionEntryHeightCalculationOperation.h"
@import ReactiveCocoa;
#import <CanvasKit1/CanvasKit1.h>
#import "DiscussionEntryCell.h"

@interface DiscussionEntryHeightCalculationOperation ()
@end

@implementation DiscussionEntryHeightCalculationOperation {
    BOOL _isFinished, _isExecuting;
}

- (void)setEntry:(CKDiscussionEntry *)entry {
    _entry = entry;
}
- (BOOL)isFinished
{
    return _isFinished;
}

- (BOOL)isExecuting
{
    return _isExecuting;
}

- (void)start
{
    [self willChangeValueForKey:@"isExecuting"];
    _isExecuting = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
    self.boundsSize = self.tableView.bounds.size;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *identifier = [DiscussionEntryCell reuseIdentifierForItem:self.entry];
        static NSInteger concurrentCount = 0;
        ++concurrentCount;
        DiscussionEntryCell *dummyCell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
        dummyCell.frame = CGRectMake(0, 0, self.boundsSize.width, dummyCell.frame.size.height);
        dummyCell.indentationLevel = self.indentationLevel;
        [dummyCell layoutSubviews];
        @weakify(self);
        dummyCell.preferredHeightHandler = ^(CGFloat height) {
            @strongify(self);
            self.completionHandler(height);
            --concurrentCount;
            [self finish];
        };
        dummyCell.entry = self.entry;
    });
}

- (BOOL)isConcurrent
{
    return YES;
}

- (void)finish
{
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    
    _isExecuting = NO;
    _isFinished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

@end
