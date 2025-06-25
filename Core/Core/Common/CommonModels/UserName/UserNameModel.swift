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

/// Stores common, username related properties. Primarily intended to be used for avatar and username display.
///
/// - parameters:
///    - name: The finalized userfacing name. May contain pronouns or already built strings like "Student 2".
///    - initials: The initials to be used for example in avatars.
///     If this is `nil`, the username is considered anonymous. It shouldn't be rebult from `name` as a fallback.
///    - avatarUrl: The remote avatar image URL. Known default avatar images will be removed.
public struct UserNameModel: Equatable, Hashable {

    // MARK: - Static

    public static let anonymousUser: UserNameModel = anonymous(isGroup: false)
    public static let anonymousGroup: UserNameModel = anonymous(isGroup: true)
    public static func anonymous(isGroup: Bool) -> UserNameModel {
        .init(name: nil, initials: nil, isGroup: isGroup)
    }

    // MARK: - Properties

    public var name: String
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
        self.name = name ?? UserNameModel.defaultName(isGroup: isGroup)
        self.initials = initials
        self.avatarUrl = avatarUrl.flatMap(User.scrubbedAvatarUrl)
        self.isGroup = isGroup
    }

    public init(user: (some UserNameProvider)?, isGroup: Bool = false) {
        self.init(
            name: user?.displayName,
            initials: user?.initials,
            avatarUrl: user?.avatarURL,
            isGroup: isGroup
        )
    }

    public init(submission: Submission, isAnonymous: Bool, isGroup: Bool, displayIndex: Int? = nil) {
        if isAnonymous {
            self.init(
                name: UserNameModel.defaultName(isGroup: isGroup, displayIndex: displayIndex),
                initials: nil,
                isGroup: isGroup
            )
        } else if isGroup {
            self.init(
                name: submission.groupName,
                initials: submission.groupName.flatMap(User.initials),
                avatarUrl: nil, // submissions has no group avatarUrl
                isGroup: true
            )
        } else {
            self.init(user: submission.user)
        }
    }

    public init(submission: Submission, assignment: Assignment?, displayIndex: Int? = nil) {
        let isAnonymous = assignment?.anonymizeStudents ?? false
        let isGradedIndividually = assignment?.gradedIndividually ?? true
        let isGroup = !isGradedIndividually && submission.groupID != nil

        self.init(submission: submission, isAnonymous: isAnonymous, isGroup: isGroup, displayIndex: displayIndex)
    }

    // MARK: - Private helpers

    private static func defaultName(isGroup: Bool, displayIndex: Int? = nil) -> String {
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

#if DEBUG

extension UserNameModel {
    static func make(
        name: String? = nil,
        initials: String? = nil,
        avatarUrl: URL? = nil,
        isGroup: Bool = false
    ) -> UserNameModel {
        UserNameModel(
            name: name,
            initials: initials,
            avatarUrl: avatarUrl,
            isGroup: isGroup
        )
    }
}

#endif
