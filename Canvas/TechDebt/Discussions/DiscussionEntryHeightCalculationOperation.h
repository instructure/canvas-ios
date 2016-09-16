//
//  DiscussionEntryHeightCalculationOperation.h
//  iCanvas
//
//  Created by Derrick Hathaway on 4/28/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKDiscussionEntry;

@interface DiscussionEntryHeightCalculationOperation : NSOperation
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic) CKDiscussionEntry *entry;
@property (nonatomic) CGSize boundsSize;
@property (nonatomic) CGFloat indentationLevel;
@property (nonatomic, copy) void (^completionHandler)(CGFloat height);
@end
