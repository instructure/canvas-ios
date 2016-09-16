//
//  WTFInsets.m
//  iCanvas
//
//  Created by derrick on 12/19/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "WTFInsets.h"

@implementation WTFInsets

- (void)setContentInset:(UIEdgeInsets)contentInset
{
    if (contentInset.bottom < 0) {
        UITableViewController *controller = (UITableViewController *)self.dataSource;
        contentInset.bottom = controller.tabBarController.tabBar.bounds.size.height;
    }
    [super setContentInset:contentInset];
}
@end
