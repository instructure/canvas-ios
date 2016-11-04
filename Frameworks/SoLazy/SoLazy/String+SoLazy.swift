
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

public extension String {
    public func toNSNumberWrappingInt64() -> NSNumber {
        return NSNumber(longLong: (self as NSString).longLongValue)
    }
    
    public func toInt64() -> Int64 {
        return self.toNSNumberWrappingInt64().longLongValue
    }

    public func isValidEmail() -> Bool {
        
        let range = NSRange(location: 0, length: self.characters.count)
        if let detector = try? NSDataDetector(types: NSTextCheckingType.Link.rawValue),
            let match = detector.firstMatchInString(self, options: NSMatchingOptions.Anchored, range: range),
            let scheme = match.URL?.scheme {
            return scheme == "mailto"
        }
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(self)
    }
}
