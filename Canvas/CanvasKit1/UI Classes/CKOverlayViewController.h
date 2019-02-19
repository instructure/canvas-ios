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

typedef enum {
    CKOverlayViewPositionTop,
    CKOverlayViewPositionMiddle,
    CKOverlayViewPositionBottom
    
} CKOverlayViewPosition;

@interface CKOverlayViewController : UIViewController
- (id)initWithView:(UIView *)view;

@property BOOL canTapBackgroundToDismiss;
@property CKOverlayViewPosition viewPosition;

@end


@interface UIViewController (CKOverlayViewController)

- (void)presentOverlayController:(CKOverlayViewController *)overlay;
- (void)dismissOverlayController;

@end