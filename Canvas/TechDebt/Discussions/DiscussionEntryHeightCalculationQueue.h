//
//  DiscussionEntryHeightCalculationQueue.h
//  iCanvas
//
//  Created by derrick on 1/17/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKDiscussionEntry.h"

@interface DiscussionEntryHeightCalculationQueue : NSObject

- (void) calculateCellHeightForEntry:(CKDiscussionEntry *)entry
                         inTableView:(UITableView *)tableView
                withIndentationLevel:(int)indentationLevel
                             handler:(void(^)(CGFloat height))handler;

- (void)cancelOutstandingHeightCalculationRequests;
@end
