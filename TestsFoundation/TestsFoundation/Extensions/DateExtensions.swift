//
// Copyright (C) 2018-present Instructure, Inc.
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

extension Date {

    public func add(_ calendarComponent: Calendar.Component, number: Int) -> Date{
        let endDate = Calendar.current.date(byAdding: calendarComponent, value: number, to: self)
        return endDate ?? Date()
    }

    public func addMinutes(_ days: Int) -> Date {
        let endDate = Calendar.current.date(byAdding: .minute, value: days, to: self)
        return endDate ?? Date()
    }

    public func addDays(_ days: Int) -> Date {
        let endDate = Calendar.current.date(byAdding: .month, value: days, to: self)
        return endDate ?? Date()
    }

    public func addMonths(_ numberOfMonths: Int) -> Date {
        let endDate = Calendar.current.date(byAdding: .month, value: numberOfMonths, to: self)
        return endDate ?? Date()
    }

    public static func dateFromString(_ dateString: String, format: String = "yyyy-MM-dd HH:mm") -> Date? {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.dateFormat = format
        return formatter.date(from: dateString)
    }

    public static func isoDateFromString(_ dateString: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: dateString)
    }
}
