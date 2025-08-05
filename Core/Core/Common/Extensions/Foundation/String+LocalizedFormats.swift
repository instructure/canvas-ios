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

extension String {

    // MARK: - "Attempt 5"

    /// Localized string for attempt number. Example: "Attempt 5"
    public static func format(attemptNumber attempt: Int) -> String {
        String.localizedStringWithFormat(String(localized: "Attempt %d", bundle: .core), attempt)
    }

    // MARK: - Items: "5 items" / "List, 5 items"

    /// Localized string for number of items. Example: "5 items"
    public static func format(numberOfItems count: Int) -> String {
        String.localizedStringWithFormat(String(localized: "d_items", bundle: .core), count)
    }
    /// Localized string for number of items. Example: "5 items"
    public static func format(numberOfItems count: Int?) -> String? {
        count.map(String.format(numberOfItems:))
    }

    /// Localized string to be used as `accessibilityLabel` for lists without a section header. Example: "List, 5 items"
    public static func format(accessibilityListCount count: Int) -> String {
        let listText = String(localized: "List", bundle: .core)
        let countText = String.format(numberOfItems: count)
        // It's okay to not translate the comma, because VoiceOver (with captions enabled) uses commas for separation,
        // even when language & region both are set to a language which doesn't (like Danish)
        return "\(listText), \(countText)"
    }

    // MARK: - "Error: Invalid start time"

    /// Localized string to be used for error messages intended for accessibility usage. Adds some context for VoiceOver users that this is an error.
    /// The `errorMessage` itself is expected to be localized already.
    /// Example: "Error: Invalid start time"
    public static func format(accessibilityErrorMessage errorMessage: String) -> String {
        let format = String(localized: "Error: %@", bundle: .core, comment: "Example: 'Error: Invalid start time'")
        return String.localizedStringWithFormat(format, errorMessage)
    }

    /// Localized string to be used for error messages intended for accessibility usage. Adds some context for VoiceOver users that this is an error.
    /// The `errorMessage` itself is expected to be localized already.
    /// Example: "Error: Invalid start time"
    public static func format(accessibilityErrorMessage errorMessage: String?) -> String? {
        errorMessage.map { String.format(accessibilityErrorMessage: $0) }
    }

    // MARK: - accessibilityLetterGrade

    /// Modifed letter grade to be used with VoiceOver.
    ///
    /// It fixes the following issues:
    /// - Grades like "B-" are read out as "B", with the "-" ommited. This method converts "-" to "minus".
    ///   Grades like "B+" are read out as "B plus" by default.
    /// - The letter "A" in grades like "A+" or "A-" is read out without emphasis. This method makes it read like a standalone letter.
    public static func format(accessibilityLetterGrade grade: String?) -> String? {
        guard let grade else { return nil }

        if grade.hasSuffix("-") {
            return "'\(String(grade.dropLast()))' \(gradeMinus)"
        }

        if grade.hasSuffix("+") {
            return "'\(String(grade.dropLast()))' +"
        }

        return "'\(grade)'"
    }
    private static let gradeMinus = String(localized: "minus", bundle: .core, comment: "As in grades 'A-' or 'C-'")
}
