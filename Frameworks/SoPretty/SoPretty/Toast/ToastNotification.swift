//
//  ToastNotification.swift
//  iCanvas
//
//  Created by Kyle Longhurst on 8/18/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
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