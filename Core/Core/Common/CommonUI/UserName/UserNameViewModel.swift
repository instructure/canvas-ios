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

public struct UserNameViewModel {

    // MARK: - Static

    public static let anonymousUser: UserNameViewModel = .init(user: nil)
    public static let anonymousGroup: UserNameViewModel = .init(group: nil)
    public static func anonymous(isGroup: Bool) -> UserNameViewModel {
        isGroup ? .anonymousGroup : .anonymousUser
    }

    // MARK: - Properties

    public var name: String?
    public var initials: String?
    public var avatarUrl: URL?
    public var isGroup: Bool

    // MARK: - Init

    public init(
        name: String?,
        initials: String?,
        avatarUrl: URL? = nil,
        isGroup: Bool = false
    ) {
        self.name = name
        self.initials = initials
        self.avatarUrl = avatarUrl.flatMap(Self.scrubbedAvatarUrl)
        self.isGroup = isGroup
    }

    public init(user: Core.User?) {
        self.init(
            name: user?.displayName,
            initials: user?.initials,
            avatarUrl: user?.avatarURL,
            isGroup: false
        )
    }

    public init(group: Core.Group?) {
        self.init(
            name: group?.name,
            initials: group?.initials,
            avatarUrl: group?.avatarURL,
            isGroup: true
        )
    }

    public init(submission: Submission, assignment: Assignment?, displayIndex: Int? = nil) {
        let isAnonym = assignment?.anonymizeStudents ?? false
        let isGroup = submission.groupID != nil

        if isAnonym {
            self.init(
                name: Self.defaultName(isGroup: isGroup, displayIndex: displayIndex),
                initials: nil,
                isGroup: isGroup
            )
        } else if isGroup {
            self.init(
                name: submission.groupName,
                initials: submission.groupName.flatMap(Self.initials),
                avatarUrl: nil, // submissions has no group avatarUrl
                isGroup: true
            )
        } else {
            self.init(user: submission.user)
        }
    }

    // MARK: - Static methods

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

    // MARK: - Private helpers

    private static func defaultName(isGroup: Bool, displayIndex: Int?) -> String {
        if let displayIndex {
            return isGroup
                ? String(localized: "Group \(displayIndex)", bundle: .core)
                : String(localized: "Student \(displayIndex)", bundle: .core)
        } else {
            return isGroup
                ? String(localized: "Group", bundle: .core)
                : String(localized: "Student", bundle: .core)
        }
    }
}

// MARK: - Extensions

extension Core.User {

    /// User's name + pronouns if any. Example: "John Doe (He/Him)"
    public var displayName: String { UserNameViewModel.displayName(name, pronouns: pronouns) }

    /// User's name + pronouns if any. Example: "John Doe (He/Him)"
    public static func displayName(_ name: String, pronouns: String?) -> String {
        UserNameViewModel.displayName(name, pronouns: pronouns)
    }

    /// User name initials, using the first two name-components. Example: "J D"
    public var initials: String { UserNameViewModel.initials(for: name) }
}

extension Core.Group {

    /// Group name initials, using the first two name-components. Example: "J D"
    public var initials: String { UserNameViewModel.initials(for: name) }
}
