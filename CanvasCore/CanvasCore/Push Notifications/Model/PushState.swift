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
    case neverShown = 0
    case shownAndAccepted
    case shownAndDeclined
    
    fileprivate static let pushPreAuthStatusKey = "com.instructure.canvas.pushPreAuthStatusKey"
    
    public static func currentPushPreAuthStatus() -> PushPreAuthStatus {
        let defaults = UserDefaults.standard
        if let status = PushPreAuthStatus(rawValue: defaults.integer(forKey: pushPreAuthStatusKey)) {
            return status
        } else {
            PushPreAuthStatus.registerDefaults()
            return PushPreAuthStatus.currentPushPreAuthStatus()
        }
    }
    
    public static func setCurrentPushPreAuthStatus(_ status: PushPreAuthStatus) {
        let defaults = UserDefaults.standard
        defaults.set(status.rawValue, forKey: pushPreAuthStatusKey)
        defaults.synchronize()
    }
    
    fileprivate static func registerDefaults() {
        let defaults = UserDefaults.standard
        defaults.register(defaults: [pushPreAuthStatusKey: PushPreAuthStatus.neverShown.rawValue])
        defaults.synchronize()
    }
}
