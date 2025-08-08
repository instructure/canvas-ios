//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

final class ISO8601DurationFormatter {
    /// Extracts and formats the duration from an ISO 8601 duration string (e.g., `"PT3H30M"`).
    ///
    /// - Parameter duration: A string representing the duration in ISO 8601 format (e.g., `"PT3H"`, `"PT45M"`, `"PT1H30M"`).
    /// - Returns: A formatted string representing the duration in hours and/or minutes.
    ///   - `"3 hours"` for `"PT3H"`
    ///   - `"30 mins"` for `"PT30M"`
    ///   - `"1 hours 20 mins"` for `"PT1H20M"`
    ///   - `"0 mins"` if no valid duration is found.
    ///
    func duration(from duration: String) -> String? {
        let regex = try? NSRegularExpression(pattern: #"PT(?:(\d+)H)?(?:(\d+)M)?"#)

        guard let match = regex?.firstMatch(in: duration, range: NSRange(duration.startIndex..., in: duration)) else {
            return nil
        }

        let extractValue: (Int) -> Int = { index in
            let range = match.range(at: index)
            return range.location != NSNotFound ? Int((duration as NSString).substring(with: range)) ?? 0 : 0
        }

        let hours = extractValue(1)
        let minutes = extractValue(2)

        switch (hours, minutes) {
        case (0, 0): return "0 \(Duration.mins.name)"
        case (_, 0): return "\(hours) \(Duration.hours.name)"
        case (0, _): return "\(minutes) \(Duration.mins.name)"
        default: return "\(hours) \(Duration.hours.name) \(minutes) \(Duration.mins.name)"
        }
    }

    enum Duration {
        case mins
        case hours
        var name: String {
            switch self {
            case .mins: return String(localized: "mins", bundle: .horizon)
            case .hours: return String(localized: "hours", bundle: .horizon)
            }
        }
    }
}
