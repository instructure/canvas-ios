//
//  PushState.swift
//  iCanvas
//
//  Created by Miles Wright on 8/17/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

public enum PushPreAuthStatus: Int {
    case NeverShown = 0
    case ShownAndAccepted
    case ShownAndDeclined
    
    private static let pushPreAuthStatusKey = "com.instructure.canvas.pushPreAuthStatusKey"
    
    public static func currentPushPreAuthStatus() -> PushPreAuthStatus {
        let defaults = NSUserDefaults.standardUserDefaults()
        if let status = PushPreAuthStatus(rawValue: defaults.integerForKey(pushPreAuthStatusKey)) {
            return status
        } else {
            PushPreAuthStatus.registerDefaults()
            return PushPreAuthStatus.currentPushPreAuthStatus()
        }
    }
    
    public static func setCurrentPushPreAuthStatus(status: PushPreAuthStatus) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setInteger(status.rawValue, forKey: pushPreAuthStatusKey)
        defaults.synchronize()
    }
    
    private static func registerDefaults() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.registerDefaults([pushPreAuthStatusKey: PushPreAuthStatus.NeverShown.rawValue])
        defaults.synchronize()
    }
}