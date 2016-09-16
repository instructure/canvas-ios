//
//  UITableViewCell+Separator.h
//  iCanvas
//
//  Created by Jason Larsen on 7/9/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableViewCell (Separator)
// In order for this crazy category to work, you need to 3 things:
//  1) set your tableView's separator style to UITableViewCellSeparatorStyleNone
//  2) make any subviews 1 pixel shorter, otherwise they will sit on top of the separator
//  3) set the background color BEFORE setting the separator line color, if you're doing a custom bg color
@property (nonatomic, strong) UIColor *separatorLineColor;
@end
