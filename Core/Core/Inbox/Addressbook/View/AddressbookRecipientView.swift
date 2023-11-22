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
    @ObservedObject private var viewModel: AddressbookRecipientViewModel
    @Environment(\.viewController) private var controller

    init(model: AddressbookRecipientViewModel) {
        self.viewModel = model
    }

    public var body: some View {
        ScrollView {
            peopleView
        }
        .searchable(text: $viewModel.searchText)
        .background(Color.backgroundLightest)
        .navigationTitle(viewModel.title)
    }

    private var separator: some View {
        Color.borderMedium
            .frame(height: 0.5)
    }

    private var peopleView: some View {
        VStack(alignment: .leading, spacing: 0) {
            separator
            if viewModel.searchText.isEmpty { allRecipient }
            ForEach(viewModel.filteredRecipients(), id: \.self) { user in
                personRowView(user)
            }
        }
    }

    private func personRowView(_ recipient: SearchRecipient) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: {
                viewModel.recipientDidTap.send((recipient: [recipient], controller: controller))
            }, label: {
                HStack(alignment: .center, spacing: 16) {
                    Avatar(name: recipient.displayName, url: recipient.avatarURL, size: 36, isAccessible: false)
                    Text(recipient.displayName ?? recipient.fullName)
                        .font(.regular16)
                        .foregroundColor(.textDarkest)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            })
            .padding(16)
            separator
        }
    }

    private var allRecipient: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: {
                viewModel.allRecipientDidTap.send((recipient: viewModel.recipients, controller: controller))
            }, label: {
                HStack(alignment: .center, spacing: 16) {
                    Avatar(name: NSLocalizedString("All", comment: ""), url: nil, size: 36, isAccessible: false)
                    VStack(alignment: .leading) {
                        Text("All in \(viewModel.roleName)", bundle: .core)
                            .font(.regular16)
                            .foregroundColor(.textDarkest)
                            .lineLimit(1)
                        Text("\(viewModel.recipients.count) People", bundle: .core)
                            .font(.regular14)
                            .foregroundColor(.textDark)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            })
            .padding(16)
            separator
        }
    }
}

#if DEBUG

struct AddressbookRecipientView_Previews: PreviewProvider {
    static let env = PreviewEnvironment()

    static var previews: some View {
        AddressBookAssembly.makePreview(env: env)
    }
}

#endif
