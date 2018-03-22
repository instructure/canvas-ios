//
//  LTITools.m
//  CanvasCore
//
//  Created by Matt Sessions on 3/9/18.
//  Copyright © 2018 Instructure, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import <CanvasCore/CanvasCore-Swift.h>
#import <UIKit/UIKit.h>

@interface AlertControls: NSObject<RCTBridgeModule>

@end

@implementation AlertControls

RCT_EXPORT_MODULE();

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

RCTResponseSenderBlock _textFieldCallback;

RCT_REMAP_METHOD(onSubmitEditing, callback:(RCTResponseSenderBlock)callback) {
    UIViewController *view = [[HelmManager shared] topMostViewController];
    if ([view isKindOfClass:[UIAlertController class]]) {
        UIAlertController *alert = (UIAlertController *)view;
        
        if (alert.textFields.count > 0) {
            UITextField *prompt = alert.textFields[0];
            [prompt addTarget:self action:@selector(onSubmitEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
            _textFieldCallback = callback;
        }
    }
}

- (void)onSubmitEditing:(UITextField *)textField {
    _textFieldCallback(@[textField.text]);
}

@end

