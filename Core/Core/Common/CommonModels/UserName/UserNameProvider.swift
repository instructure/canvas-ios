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

public protocol UserNameProvider {
    var name: String { get }
    var pronouns: String? { get }
    var avatarURL: URL? { get }

    /// User's name + pronouns if any. Example: "John Doe (He/Him)"
    var displayName: String { get }

    /// User name initials, using the first two name-components. Example: "J D"
    var initials: String { get }
}

extension UserNameProvider {
    // Not required properties
    public var pronouns: String? { nil }
    public var avatarURL: URL? { nil }

    // Convenience accessors
    public var displayName: String { Self.displayName(name, pronouns: pronouns) }
    public var initials: String { Self.initials(for: name) }
}

// MARK: - User name logic

extension UserNameProvider {
    /// User's name + pronouns if any. Example: "John Doe (He/Him)"
    public static func displayName(_ name: String, pronouns: String?) -> String {
        if let pronouns {
            let format = NSLocalizedString("User.displayName", bundle: .core, value: "%@ (%@)", comment: "Name and pronouns - John (He/Him)")
            return String.localizedStringWithFormat(format, name, pronouns)
        }
        return name
    }

    /// User's initials, using the first two name-components. Example: "J D"
    public static func initials(for name: String) -> String {
        name
            .split(separator: " ", maxSplits: 1)
            .reduce("") { (value: String, part: Substring) -> String in
                guard let char = part.first else { return value }
                return "\(value)\(char)"
            }
            .localizedUppercase
    }

    /// "Ignore crappy default avatars." (as quoted from the original description)
    public static func scrubbedAvatarUrl(_ url: URL?) -> URL? {
        guard let absoluteString = url?.absoluteString else { return nil }

        if absoluteString.contains("images/dotted_pic.png") || absoluteString.contains("images/messages/avatar-50.png") {
            return nil
        }
        return url
    }
}
