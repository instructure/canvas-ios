
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
import Marshal

extension NSDate : ValueType {
    public static func value(object: Any) throws -> NSDate {
        guard let dateString = object as? String else {
            throw Error.TypeMismatch(expected: String.self, actual: object.dynamicType)
        }
        guard let date = NSDate.fromISO8601String(dateString) else {
            throw Error.TypeMismatch(expected: "ISO8601 date string", actual: dateString)
        }
        return date
    }
}

public let ISO8601MillisecondFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ";
    let tz = NSTimeZone(abbreviation:"GMT")
    formatter.timeZone = tz
    return formatter
}()

public let ISO8601SecondFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ";
    let tz = NSTimeZone(abbreviation:"GMT")
    formatter.timeZone = tz
    return formatter
}()

private let formatters = [ISO8601MillisecondFormatter, ISO8601SecondFormatter]

public extension NSDate {
    static func fromISO8601String(dateString: String) -> NSDate? {
        for formatter in formatters {
            if let date = formatter.dateFromString(dateString) {
                return date
            }
        }
        return .None
    }
}
