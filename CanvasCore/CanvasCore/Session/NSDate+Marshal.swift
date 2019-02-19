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
import Marshal

extension Date : ValueType {
    public static func value(from object: Any) throws -> Date {
        guard let dateString = object as? String else {
            throw MarshalError.typeMismatch(expected: String.self, actual: type(of: object))
        }
        guard let date = Date.fromISO8601String(dateString) else {
            throw MarshalError.typeMismatch(expected: "ISO8601 date string", actual: dateString)
        }
        return date
    }
}

public let ISO8601MillisecondFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ";
    let tz = TimeZone(abbreviation:"GMT")
    formatter.timeZone = tz
    return formatter
}()

public let ISO8601SecondFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ";
    let tz = TimeZone(abbreviation:"GMT")
    formatter.timeZone = tz
    return formatter
}()

private let formatters = [ISO8601MillisecondFormatter, ISO8601SecondFormatter]

public extension Date {
    static func fromISO8601String(_ dateString: String) -> Date? {
        for formatter in formatters {
            if let date = formatter.date(from: dateString) {
                return date
            }
        }
        return .none
    }
}
