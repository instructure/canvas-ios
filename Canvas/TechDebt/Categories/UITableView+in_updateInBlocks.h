//
//  UITableView+in_updateInBlocks.h
//  iCanvas
//
//  Created by BJ Homer on 2/3/12.
//  Copyright (c) 2012 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (in_updateInBlocks)

- (void)in_updateWithBlock:(void (^)(void))block;

@end
