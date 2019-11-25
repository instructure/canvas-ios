//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import Foundation

public extension Date {
    func isoString() -> String {
        return ISO8601DateFormatter.string(from: self, timeZone: TimeZone(abbreviation: "UTC")!, formatOptions: .withInternetDateTime)
    }

    init?(fromISOString: String, formatOptions: ISO8601DateFormatter.Options? = nil) {
        let formatter = ISO8601DateFormatter()
        if let options = formatOptions {
            formatter.formatOptions = options
        }
        guard let date = formatter.date(from: fromISOString) else { return nil }
        self = date
    }

    func addYears(_ years: Int) -> Date {
        return Calendar.current.date(byAdding: .year, value: years, to: self) ?? Date()
    }
}
