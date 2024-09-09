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

struct RecipientFilterView: View {
    // MARK: - Properties
    let recipients: [Recipient]
    var didSelectRecipient: ((Recipient) -> Void)

    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack {
                ForEach(recipients, id: \.self) { recipient in
                    Button {
                        didSelectRecipient(recipient)
                    } label: {
                        RecipientFilterRow(recipient: recipient, isShowSeparator: recipient != recipients.last)
                            .frame(minHeight: 50)
                            .accessibilityLabel(recipient.displayName)
                            .accessibility(hint: Text("Double tap to select", bundle: .core))
                    }
                }
            }
            .background(Color.backgroundLightest)
        }
        .shadow(color: Color.textDark.opacity(0.2), radius: 5, x: 0, y: 0)
        .padding(5)
    }
}

#if DEBUG
#Preview {
    let imageUrl = URL(string: "https://png.pngtree.com/thumb_back/fh260/background/20230614/pngtree-cartoon-image-of-a-bearded-man-with-glasses-image_2876117.jpg")
    return RecipientFilterView(recipients: [
        .init(id: "1", name: "Canvas IOS 1", avatarURL: imageUrl),
        .init(id: "2", name: "Canvas", avatarURL: imageUrl),
        .init(id: "3", name: "Canvas Test ", avatarURL: imageUrl),
        .init(id: "4", name: "Canvas 3", avatarURL: imageUrl),
        .init(id: "5", name: "Canvas IOS16", avatarURL: imageUrl)
    ]) { _ in }
}

#endif
