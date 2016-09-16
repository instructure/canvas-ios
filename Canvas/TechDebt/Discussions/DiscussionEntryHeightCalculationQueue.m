//
//  DiscussionEntryHeightCalculationQueue.m
//  iCanvas
//
//  Created by derrick on 1/17/14. 
//  Copyright (c) 2014 Instructure. All rights reserved.
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
