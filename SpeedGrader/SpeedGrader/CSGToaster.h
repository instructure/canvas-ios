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

#import <Foundation/Foundation.h>
@import CWStatusBarNotification;

@interface CSGToaster : NSObject

// Status bar toasts are for notifications that users can't interact with, e.g. "message sent"
- (CWStatusBarNotification *)statusBarToast:(NSString *)message Color:(UIColor *)color;
- (void)statusBarToast:(NSString *)message Color:(UIColor *)color Duration:(CGFloat)duration;

#pragma mark - Other Toasts
// TODO implement toasts (probably popping over navbar) that when user taps them, have an action.

@end
