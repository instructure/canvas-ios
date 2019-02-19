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

@class CBIColorfulViewModel;
@interface CBIColorfulCell : UITableViewCell
@property (nonatomic) CBIColorfulViewModel *viewModel;
@property (nonatomic, getter=isIconRound) BOOL roundIcon;

@property IBOutlet UIImageView *customIcon;
@property IBOutlet UILabel *customTitleLabel;
@property IBOutlet UILabel *customDetailLabel;

// called on tap and to reflect selection override as needed
// to reflect highlighted/selected state
- (void)updateHighlight;

@property (nonatomic) UIView *highlightedAccessoryView;
@property (nonatomic) UIView *nonHighlightedAccessoryView;

@end
