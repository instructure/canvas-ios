//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    
    

import Foundation
import CWStatusBarNotification

public class ToastManager : NSObject {
    
    let defaultToastDuration = 1.65
    var notification: CWStatusBarNotification
    
    public override init () {
        notification = CWStatusBarNotification()
    }
    
    // ---------------------------------------------
    // MARK: - Default Duration
    // ---------------------------------------------
    
    public func statusBarToastSuccess(message: String) {
        createToastWithColorAndDefaultDuration(message, color: UIColor.toastSuccess)
    }
    
    public func statusBarToastInfo(message: String) {
        createToastWithColorAndDefaultDuration(message, color: UIColor.toastInfo)
    }
    
    public func statusBarToastFailure(message: String) {
        createToastWithColorAndDefaultDuration(message, color: UIColor.toastFailure)
    }
    
    func createToastWithColorAndDefaultDuration(message: String, color: UIColor) {
        notification.notificationLabelBackgroundColor = color
        notification.displayNotificationWithMessage(message, forDuration: defaultToastDuration)
    }
    
    // ---------------------------------------------
    // MARK: - With Completion Block
    // ---------------------------------------------
    
    public func statusBarToastSuccess(message: String, completion: (() -> ())?) {
        createToastWithColorAndCompletionBlock(message, color: UIColor.toastSuccess, completion: completion)
    }
    
    public func statusBarToastInfo(message: String, completion: (() -> ())?) {
        createToastWithColorAndCompletionBlock(message, color: UIColor.toastInfo, completion: completion)
    }
    
    public func statusBarToastFailure(message: String, completion: (() -> ())?) {
        createToastWithColorAndCompletionBlock(message, color: UIColor.toastFailure, completion: completion)
    }
    
    func createToastWithColorAndCompletionBlock(message: String, color: UIColor, completion: (() -> ())?) {
        notification.notificationLabelBackgroundColor = color
        notification.displayNotificationWithMessage(message) {
            completion?()
        }
    }
    
    // ---------------------------------------------
    // MARK: - Dismissing Notification
    // ---------------------------------------------
    
    public func dismissNotification() {
        notification.dismissNotification()
    }
}