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

#import "HapticFeedback.h"
#import <UIKit/UIKit.h>

@implementation HapticFeedback
{
    UIImpactFeedbackGenerator *_lightImpactFeedback;
    UIImpactFeedbackGenerator *_mediumImpactFeedback;
    UIImpactFeedbackGenerator *_heavyImpactFeedback;
    
    UINotificationFeedbackGenerator *_notificationFeedback;
    
    UISelectionFeedbackGenerator *_selectionFeedback;
}

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE()

- (void)setBridge:(RCTBridge *)bridge {
    _bridge = bridge;
    
    _lightImpactFeedback = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
    _mediumImpactFeedback = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
    _heavyImpactFeedback = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleHeavy];
    
    _notificationFeedback = [[UINotificationFeedbackGenerator alloc] init];
    
    _selectionFeedback = [[UISelectionFeedbackGenerator alloc] init];
}

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

RCT_EXPORT_METHOD(generate:(NSString *)type)
{
    if ([type isEqualToString:@"light-impact"]) {
        [_lightImpactFeedback impactOccurred];
    } else if ([type isEqualToString:@"medium-impact"]) {
        [_mediumImpactFeedback impactOccurred];
    } else if ([type isEqualToString:@"heavy-impact"]) {
        [_heavyImpactFeedback impactOccurred];
    } else if ([type isEqualToString:@"warning-notification"]) {
        [_notificationFeedback notificationOccurred:UINotificationFeedbackTypeWarning];
    } else if ([type isEqualToString:@"error-notification"]) {
        [_notificationFeedback notificationOccurred:UINotificationFeedbackTypeError];
    } else if ([type isEqualToString:@"success-notification"]) {
        [_notificationFeedback notificationOccurred:UINotificationFeedbackTypeSuccess];
    } else if ([type isEqualToString:@"selection"]) {
        [_selectionFeedback selectionChanged];
    }
}

RCT_EXPORT_METHOD(prepare)
{
    // awake the taptic engine, only prepare one of them
    [_selectionFeedback prepare];
}

@end
