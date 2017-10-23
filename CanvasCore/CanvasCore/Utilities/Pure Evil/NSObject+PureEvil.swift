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
import ObjectiveC

extension NSObject {
    public func getAssociatedObject<T>(_ key: UnsafeRawPointer) -> T? {
        guard let asT = objc_getAssociatedObject(self, key) as? T else {
            return nil
        }

        return asT
    }
    
    public func setAssociatedObject<T: AnyObject>(_ value: T?, forKey key: UnsafeRawPointer, policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN) {
        objc_setAssociatedObject(self, key, value, policy)
    }
}
