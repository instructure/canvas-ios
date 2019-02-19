//
// Copyright (C) 2018-present Instructure, Inc.
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

