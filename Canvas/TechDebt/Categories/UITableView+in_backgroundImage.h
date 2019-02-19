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

// Inserting the '_' in these method names to avoid method name collisions

@interface UITableViewCell (ic_backgroundImage)
@property (nonatomic) UIImage *icBackgroundImage;
@property (nonatomic) UIImage *icBackgroundHighlightedImage;
@end

@interface UITableView (ic_backgroundImage)
@property (nonatomic) UIImage *icBackgroundImage;
@end

@interface UILabel (ic_textColor)
@property (nonatomic) UIColor *icTextColor;
@end
