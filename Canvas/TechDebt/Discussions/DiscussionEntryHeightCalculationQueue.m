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
    
    

#import "DiscussionEntryHeightCalculationQueue.h"
#import <CanvasKit1/CanvasKit1.h>
#import "DiscussionEntryCell.h"
#import "EXTScope.h"
#import "DiscussionEntryHeightCalculationOperation.h"

@interface DiscussionEntryHeightCalculationQueue ()
@property (nonatomic) NSOperationQueue *opQueue;
@end

@implementation DiscussionEntryHeightCalculationQueue

- (id)init
{
    self = [super init];
    if (self) {
        _opQueue = [NSOperationQueue new];
        _opQueue.maxConcurrentOperationCount = 2;
    }
    return self;
}

- (void)dealloc
{
    [_opQueue cancelAllOperations];
}

- (void) calculateCellHeightForEntry:(CKDiscussionEntry *)entry
                         inTableView:(UITableView *)tableView
                withIndentationLevel:(int)indentationLevel
                             handler:(void(^)(CGFloat height))handler {
    DiscussionEntryHeightCalculationOperation *operation = [[DiscussionEntryHeightCalculationOperation alloc] init];
    
    operation.entry = entry;
    operation.tableView = tableView;
    operation.indentationLevel = indentationLevel;
    operation.completionHandler = handler;
    
    [self.opQueue addOperation:operation];
}

- (void)cancelOutstandingHeightCalculationRequests
{
    [self.opQueue cancelAllOperations];
}

@end
