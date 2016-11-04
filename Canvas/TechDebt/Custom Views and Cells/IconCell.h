
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
#import <CanvasKit1/CanvasKit1.h>

@interface IconCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *leftSideContainerView;
@property (nonatomic) IBOutlet CKRemoteImageView *orangeImageView;
@property (nonatomic) IBOutlet CKRemoteImageView *whiteImageView;
@property (nonatomic) CGFloat imageViewWidth;

@property (nonatomic) CGFloat cellPadding;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (nonatomic) BOOL allWhiteStyle;
@end


@interface IconCell (ModuleItemCell)
@property (nonatomic) BOOL sequentialChecked;
@property (nonatomic) BOOL sequentialUnchecked;
@end


@interface UITableView (IconCell)
- (void)registerIconCellForReuse;
- (IconCell *)dequeueReusableIconCellForIndexPath:(NSIndexPath *)indexPath;
@end