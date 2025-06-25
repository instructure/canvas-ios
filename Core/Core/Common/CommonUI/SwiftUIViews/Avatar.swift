//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

import SwiftUI

public struct Avatar: View {
    public static let defaultSize: CGFloat = 40

    private let initials: String?
    private let url: URL?
    private let size: CGFloat
    private let isGroup: Bool
    private let isAccessible: Bool

    public init(name: String?, url: URL?, size: CGFloat = Avatar.defaultSize, isAccessible: Bool = false) {
        if let name {
            initials = UserNameViewModel.initials(for: name)
        } else {
            initials = nil
        }
        self.url = Avatar.scrubbedURL(url)
        self.isGroup = false // for backwards compatibility
        self.size = size
        self.isAccessible = isAccessible
    }

    public init(model: UserNameViewModel, size: CGFloat = Avatar.defaultSize, isAccessible: Bool = false) {
        self.initials = model.initials
        self.url = model.avatarUrl
        self.isGroup = model.isGroup
        self.size = size
        self.isAccessible = isAccessible
    }

    public var body: some View {
        if let url = url {
            RemoteImage(url, width: size, height: size)
                .aspectRatio(contentMode: .fill)
                .accessibility(hidden: !isAccessible)
                .background(Color.backgroundLight)
                .cornerRadius(size / 2)
                .identifier("Avatar.imageView")
        } else if let initials {
            Text(initials)
                .accessibility(hidden: !isAccessible)
                .allowsTightening(true)
                .font(Font(UIFont.applicationFont(ofSize: size / 2.25, weight: .semibold)))
                .foregroundColor(.textDark)
                .frame(width: size, height: size)
                .background(Color.backgroundLightest)
                .cornerRadius(size / 2)
                .overlay(Circle()
                    .stroke(Color.borderMedium, lineWidth: 1)
                )
                .identifier("Avatar.initialsLabel")
        } else {
            (isGroup ? Image.groupLine : Image.userLine)
                .aspectRatio(contentMode: .fill)
                .frame(width: size, height: size)
                .accessibility(hidden: !isAccessible)
                .foregroundColor(.textDark)
                .background(Color.backgroundLightest)
                .cornerRadius(size / 2)
                .overlay(Circle()
                    .stroke(Color.borderMedium, lineWidth: 1)
                )
                .identifier(isGroup ? "Avatar.anonymousGroup" : "Avatar.anonymousUser")
        }
    }

    /// Ignore crappy default avatars.
    static func scrubbedURL(_ url: URL?) -> URL? {
        UserNameViewModel.scrubbedAvatarUrl(url)
    }
}

#Preview {
    HStack {
        Avatar(name: "John Doe", url: nil)
        Avatar(name: nil, url: nil)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.black)

}
