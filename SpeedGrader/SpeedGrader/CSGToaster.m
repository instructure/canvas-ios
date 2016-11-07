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

#import "CSGToaster.h"
#import "UIColor+Canvas.h"

static float DefaultToastDuration = 2.65f;

@interface CSGToaster ()

@end

@implementation CSGToaster

#pragma mark - Status Bar Toasts

- (CWStatusBarNotification *)statusBarToast:(NSString *)message Color:(UIColor *)color
{
    CWStatusBarNotification *notification = [[CWStatusBarNotification alloc] init];
    notification.notificationAnimationInStyle = CWNotificationAnimationStyleTop;
    notification.notificationAnimationOutStyle = CWNotificationAnimationStyleTop;
    notification.notificationLabelTextColor = [UIColor whiteColor];
    notification.notificationLabelBackgroundColor = color;
    
    [notification displayNotificationWithMessage:message forDuration:DefaultToastDuration];
    return notification;
}

- (void)statusBarToast:(NSString *)message Color:(UIColor *)color Duration:(CGFloat)duration
{
    CWStatusBarNotification *notification = [[CWStatusBarNotification alloc] init];
    notification.notificationAnimationInStyle = CWNotificationAnimationStyleTop;
    notification.notificationAnimationOutStyle = CWNotificationAnimationStyleTop;
    notification.notificationLabelTextColor = [UIColor whiteColor];
    notification.notificationLabelBackgroundColor = color;
    
    [notification displayNotificationWithMessage:message forDuration:duration];
}


@end
