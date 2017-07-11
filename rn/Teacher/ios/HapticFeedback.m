//
//  HapticFeedback.m
//  Teacher
//
//  Created by Ben Kraus on 7/10/17.
//  Copyright © 2017 Instructure. All rights reserved.
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
