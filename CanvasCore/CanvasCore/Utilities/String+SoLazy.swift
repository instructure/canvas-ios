//
// Copyright (C) 2016-present Instructure, Inc.
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
