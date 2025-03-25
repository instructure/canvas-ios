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

public struct ListFormatter {
    public enum Conjunction {
        case and, or
    }

    /// Localize a list of `String`s into a single `String`.
    ///
    /// See http://cldr.unicode.org/development/development-process/design-proposals/list-formatting
    public static func localizedString(from list: [String], conjunction: Conjunction = .and) -> String {
        if conjunction == .and {
            return Foundation.ListFormatter.localizedString(byJoining: list)
        }
        var two, start, middle, end: String
        switch conjunction {
        case .and:
            two = NSLocalizedString("list_and_two", bundle: .core, value: "%@ and %@", comment: "and list pattern for 2 items")
            start = NSLocalizedString("list_and_start", bundle: .core, value: "%@, %@", comment: "start of and list pattern")
            middle = NSLocalizedString("list_and_middle", bundle: .core, value: "%@, %@", comment: "middle of and list pattern")
            end = NSLocalizedString("list_and_end", bundle: .core, value: "%@, and %@", comment: "end of and list pattern")
        case .or:
            two = NSLocalizedString("list_or_two", bundle: .core, value: "%@ or %@", comment: "or list pattern for 2 items")
            start = NSLocalizedString("list_or_start", bundle: .core, value: "%@, %@", comment: "start of or list pattern")
            middle = NSLocalizedString("list_or_middle", bundle: .core, value: "%@, %@", comment: "middle of or list pattern")
            end = NSLocalizedString("list_or_end", bundle: .core, value: "%@, or %@", comment: "end of or list pattern")
        }
        switch list.count {
        case 0: return ""
        case 1: return list[0]
        case 2: return String.localizedStringWithFormat(two, list[0], list[1])
        default:
            var string = String.localizedStringWithFormat(end, list[list.count - 2], list[list.count - 1])
            var i = list.count - 3
            while i >= 1 {
                string = String.localizedStringWithFormat(middle, list[i], string)
                i -= 1
            }
            return String.localizedStringWithFormat(start, list[0], string)
        }
    }
}
