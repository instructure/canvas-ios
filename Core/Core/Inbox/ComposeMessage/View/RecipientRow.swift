//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

struct RecipientRow: View {
    // MARK: - Properties
    let recipient: Recipient
    let showSeparator: Bool
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 13) {
                if let imageUrl = recipient.avatarURL {
                    RemoteImage(imageUrl, width: 36, height: 36)
                        .clipShape(Circle())
                }
                Text(recipient.displayName)
                    .font(.regular16)
                    .foregroundStyle(Color.textDark)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityHidden(true)

            }
            .background(Color.backgroundLightest)
            .padding(.horizontal, 15)
            .padding(.vertical, 7)
            InstUI.Divider()
                .opacity(showSeparator ? 1 : 0)
        }
    }
}

#if DEBUG
#Preview {
    RecipientRow(
        recipient: .init(
            id: "1",
            name: "Canvas IOS",
            avatarURL: URL(string: "https://png.pngtree.com/thumb_back/fh260/background/20230614/pngtree-cartoon-image-of-a-bearded-man-with-glasses-image_2876117.jpg")
        ), showSeparator: true
    )
}

#endif
