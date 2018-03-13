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
        return NSNumber(value: (self as NSString).longLongValue as Int64)
    }
    
    public func toInt64() -> Int64 {
        return self.toNSNumberWrappingInt64().int64Value
    }

    public func isValidEmail() -> Bool {
        
        let range = NSRange(location: 0, length: self.count)
        if let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue),
            let match = detector.firstMatch(in: self, options: NSRegularExpression.MatchingOptions.anchored, range: range),
            let scheme = match.url?.scheme {
            return scheme == "mailto"
        }
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
}
