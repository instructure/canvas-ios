
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

/**
 Feel free to subclass this.
 
 Just set the master and detail view controllers.
 */
@interface CBISplitViewController : UIViewController

@property (nonatomic) BOOL isDetailToMasterTransition;

@property (nonatomic) UIViewController *master;
@property (nonatomic) UIViewController *detail;

@property (nonatomic, readonly) NSLayoutConstraint *masterWidthConstraint, *masterXOffsetConstraint, *detailWidthConstraint, *detailXOffsetConstraint;

- (void)layoutMasterAndDetailViews;

- (void)pushNextDetailViewController:(UIViewController *)nextDetailViewController animated:(BOOL)animated;

@end


@interface UIViewController (CBISplitViewController)
@property (nonatomic, readonly) CBISplitViewController *cbi_splitViewController;
@end