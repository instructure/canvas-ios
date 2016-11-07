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