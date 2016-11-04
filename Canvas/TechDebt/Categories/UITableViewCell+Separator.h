
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
    
    

#import <UIKit/UIKit.h>

@interface UITableViewCell (Separator)
// In order for this crazy category to work, you need to 3 things:
//  1) set your tableView's separator style to UITableViewCellSeparatorStyleNone
//  2) make any subviews 1 pixel shorter, otherwise they will sit on top of the separator
//  3) set the background color BEFORE setting the separator line color, if you're doing a custom bg color
@property (nonatomic, strong) UIColor *separatorLineColor;
@end
