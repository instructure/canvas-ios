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
import CWNotification

public class ToastManager : NSObject {
    
    let defaultToastDuration = 1.65
    var notification: CWStatusBarNotification
    
    public override init () {
        notification = CWStatusBarNotification()
    }
    
    // ---------------------------------------------
    // MARK: - Default Duration
    // ---------------------------------------------
    
    public func statusBarToastSuccess(_ message: String) {
        createToastWithColorAndDefaultDuration(message, color: UIColor.toastSuccess)
    }
    
    public func statusBarToastInfo(_ message: String) {
        createToastWithColorAndDefaultDuration(message, color: UIColor.toastInfo)
    }
    
    public func statusBarToastFailure(_ message: String) {
        createToastWithColorAndDefaultDuration( message, color: UIColor.toastFailure)
    }
    
    func createToastWithColorAndDefaultDuration(_ message: String, color: UIColor) {
        notification.notificationLabelBackgroundColor = color
        notification.display(withMessage: message, forDuration: defaultToastDuration)
    }
    
    // ---------------------------------------------
    // MARK: - With Completion Block
    // ---------------------------------------------
    
    public func statusBarToastSuccess(_ message: String, completion: (() -> ())?) {
        createToastWithColorAndCompletionBlock(message, color: UIColor.toastSuccess, completion: completion)
    }
    
    public func statusBarToastInfo(_ message: String, completion: (() -> ())?) {
        createToastWithColorAndCompletionBlock(message, color: UIColor.toastInfo, completion: completion)
    }
    
    public func statusBarToastFailure(_ message: String, completion: (() -> ())?) {
        createToastWithColorAndCompletionBlock(message, color: UIColor.toastFailure, completion: completion)
    }
    
    func createToastWithColorAndCompletionBlock(_ message: String, color: UIColor, completion: (() -> ())?) {
        notification.notificationLabelBackgroundColor = color
        notification.display(withMessage: message) {
            completion?()
        }
    }
    
    // ---------------------------------------------
    // MARK: - Dismissing Notification
    // ---------------------------------------------
    
    public func dismissNotification() {
        notification.dismiss()
    }
}
