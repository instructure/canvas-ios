//
//  UITableView+in_updateInBlocks.m
//  iCanvas
//
//  Created by BJ Homer on 2/3/12.
//  Copyright (c) 2012 Instructure. All rights reserved.
//

#import "UITableView+in_updateInBlocks.h"

@implementation UITableView (in_updateInBlocks)

- (void)in_updateWithBlock:(void (^)(void))block {
    [self beginUpdates];
    block();
    [self endUpdates];
}

@end
