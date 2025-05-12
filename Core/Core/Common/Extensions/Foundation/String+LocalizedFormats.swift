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

    /// Localized string to be used when we need number of items. Example: "5 items"
    public static func localizedNumberOfItems(_ count: Int) -> String {
        String.localizedStringWithFormat(String(localized: "d_items", bundle: .core), count)
    }

    /// Localized string to be used as `accessibilityLabel` for lists without a section header. Example: "List, 5 items"
    public static func localizedAccessibilityListCount(_ count: Int) -> String {
        let listText = String(localized: "List", bundle: .core)
        let countText = String.localizedNumberOfItems(count)
        // It's okay to not translate the comma, because VoiceOver (with captions enabled) uses commas for separation,
        // even when language & region both are set to a language which doesn't (like Danish)
        return "\(listText), \(countText)"
    }

    /// Localized string to be used for error messages intended for accessibility usage. Adds some context for VoiceOver users that this is an error.
    /// The `errorMessage` itself is expected to be localized already.
    /// Example: "Error: Invalid start time"
    public static func localizedAccessibilityErrorMessage(_ errorMessage: String) -> String {
        let format = String(localized: "Error: %@", bundle: .core, comment: "Example: 'Error: Invalid start time'")
        return String.localizedStringWithFormat(format, errorMessage)
    }

    /// Localized string to be used for error messages intended for accessibility usage. Adds some context for VoiceOver users that this is an error.
    /// The `errorMessage` itself is expected to be localized already.
    /// Example: "Error: Invalid start time"
    public static func localizedAccessibilityErrorMessage(_ errorMessage: String?) -> String? {
        errorMessage.map { String.localizedAccessibilityErrorMessage($0) }
    }

    /// Localized string to be used when we need attempt number. Example: "Attempt 5"
    public static func localizedAttemptNumber(_ attempt: Int) -> String {
        String.localizedStringWithFormat(String(localized: "Attempt %d", bundle: .core), attempt)
    }
}
