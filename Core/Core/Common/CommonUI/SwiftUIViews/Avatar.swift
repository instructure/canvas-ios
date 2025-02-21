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
    public let initials: String?
    public let url: URL?
    public let size: CGFloat
    private let isAccessible: Bool

    public init(name: String?, url: URL?, size: CGFloat = 40, isAccessible: Bool = false) {
        if let name {
            initials = Avatar.initials(for: name)
        } else {
            initials = nil
        }
        self.url = Avatar.scrubbedURL(url)
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
                .testID("Avatar.imageView")
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
                .testID("Avatar.initialsLabel")
        } else {
            Image.userLine
                .aspectRatio(contentMode: .fill)
                .frame(width: size, height: size)
                .accessibility(hidden: !isAccessible)
                .foregroundColor(.textDark)
                .background(Color.backgroundLightest)
                .cornerRadius(size / 2)
                .overlay(Circle()
                    .stroke(Color.borderMedium, lineWidth: 1)
                )
                .testID("Avatar.anonymousUser")
        }
    }

    static func scrubbedURL(_ url: URL?) -> URL? {
        // Ignore crappy default avatars.
        if url?.absoluteString.contains("images/dotted_pic.png") == true || url?.absoluteString.contains("images/messages/avatar-50.png") == true {
            return nil
        }
        return url
    }

    static func initials(for name: String) -> String {
        return name.split(separator: " ", maxSplits: 1).reduce("") { (value: String, part: Substring) -> String in
            guard let char = part.first else { return value }
            return "\(value)\(char)"
        }.localizedUppercase
    }

    public struct Anonymous: View {
        let isGroup: Bool
        let size: CGFloat

        public init(isGroup: Bool = false, size: CGFloat = 40) {
            self.isGroup = isGroup
            self.size = size
        }

        public var body: some View {
            (isGroup ? Image.groupLine : Image.userLine)
                .foregroundColor(.textDark)
                .frame(width: size, height: size)
                .cornerRadius(size / 2)
                .overlay(Circle()
                    .stroke(Color.borderMedium, lineWidth: 1)
                )
        }
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
