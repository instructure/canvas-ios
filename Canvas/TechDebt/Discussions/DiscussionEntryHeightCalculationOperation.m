
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
