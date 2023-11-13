//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

public struct AddressbookRecipientView: View {
    @ObservedObject private var model: AddressbookRecipientViewModel
    @Environment(\.viewController) private var controller

    init(model: AddressbookRecipientViewModel) {
        self.model = model
    }

    public var body: some View {
        ScrollView {
            ForEach(model.recipients, id: \.id) { recipient in
                VStack(spacing: 0) {
                    Color.borderMedium
                        .frame(height: 0.5)
                    Button(action: {
                        model.recipientDidTap.send((recipient: [recipient], controller: controller))
                    }, label: {
                        peopleRowView(recipient)
                    })
                    .padding(16)
                }
            }
        }
        .background(Color.backgroundLightest)
        .navigationTitle(model.title)
    }

    @ViewBuilder
    private func peopleRowView(_ recipient: SearchRecipient) -> some View {
        HStack(alignment: .center, spacing: 16) {
            Avatar(name: recipient.name, url: recipient.avatarURL, size: 36, isAccessible: false)
            Text(recipient.displayName ?? recipient.name)
                    .font(.regular16)
                    .foregroundColor(.textDarkest)
                    .lineLimit(1)
            Spacer()
        }
    }
}
