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

struct AddressbookRoleView: View {
    @ObservedObject private var viewModel: AddressbookRoleViewModel
    @Environment(\.viewController) private var controller

    init(model: AddressbookRoleViewModel) {
        self.viewModel = model
    }

    public var body: some View {
        ScrollView {
            switch viewModel.state {
            case .loading:
                loadingIndicator
            case .data:
                if viewModel.isRolesViewVisible {
                    rolesView
                } else {
                    peopleView
                }
            case .empty, .error:
                Text("There was an error loading recipients.\nPull to refresh to try again.", bundle: .core)
                    .foregroundColor(.textDark)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
        }
        .searchable(
            text: Binding { viewModel.searchText.value } set: { viewModel.searchText.send($0) },
            placement: .navigationBarDrawer(displayMode: .always)
        )
        .refreshable {
            await viewModel.refresh()
        }
        .background(Color.backgroundLightest)
        .navigationTitle(viewModel.title)
        .navigationBarItems(trailing: doneButton)
    }

    private var loadingIndicator: some View {
        ProgressView()
            .progressViewStyle(.indeterminateCircle())
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .accentColor(Color(Brand.shared.primary))
            .padding()
    }

    private var separator: some View {
        Color.borderMedium
            .frame(height: 0.5)
    }

    private var doneButton: some View {
        Button {
            viewModel.doneButtonDidTap.accept(controller)
        } label: {
            Text("Done", bundle: .core)
                .font(.regular16)
                .foregroundColor(.accentColor)
        }
    }

    private var peopleView: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(viewModel.recipients, id: \.self) { user in
                personRowView(user)
            }
        }
    }

    private func personRowView(_ recipient: Recipient) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: {
                viewModel.recipientDidTap.send(recipient)
            }, label: {
                HStack(alignment: .center, spacing: 16) {
                    Avatar(name: recipient.displayName, url: recipient.avatarURL, size: 36, isAccessible: false)
                    Text(recipient.displayName)
                        .font(.regular16)
                        .foregroundColor(.textDarkest)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer()
                    Image.checkSolid
                        .resizable()
                        .foregroundColor(.textDarkest)
                        .frame(width: 24, height: 24)
                        .padding(.horizontal, 12)
                        .accessibilityLabel(Text("Selected", bundle: .core))
                        .hidden(!viewModel.selectedRecipients.contains(recipient))
                }
            })
            .padding(16)
            separator
        }
    }

    private var rolesView: some View {
        VStack(alignment: .leading, spacing: 0) {
            separator
            if viewModel.isAllRecipientButtonVisible { allRecipient }
            ForEach(viewModel.roles, id: \.self) { role in
                roleRowView(role)
            }
        }
    }

    private func roleRowView(_ role: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: {
                viewModel.roleDidTap.send((roleName: role, recipients: viewModel.roleRecipients[role] ?? [], controller: controller))
            }, label: {
                HStack(alignment: .center, spacing: 16) {
                    Avatar(name: role, url: nil, size: 36, isAccessible: false)
                    VStack(alignment: .leading, spacing: 8) {
                        Text(role)
                            .font(.regular16)
                            .foregroundColor(.textDarkest)
                            .lineLimit(1)
                        Text("\(viewModel.roleRecipients[role]?.count ?? 0) People", bundle: .core)
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

    private var allRecipient: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: {
                viewModel.recipientDidTap.send(viewModel.allRecipient)
            }, label: {
                HStack(alignment: .center, spacing: 16) {
                    Avatar(name: String(localized: "All", bundle: .core), url: nil, size: 36, isAccessible: false)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("All in \(viewModel.recipientContext.name)", bundle: .core)
                            .font(.regular16)
                            .foregroundColor(.textDarkest)
                            .lineLimit(1)
                        Text("\(viewModel.recipients.count) People", bundle: .core)
                            .font(.regular14)
                            .foregroundColor(.textDark)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer()
                    Image.checkSolid
                        .resizable()
                        .foregroundColor(.textDarkest)
                        .frame(width: 24, height: 24)
                        .padding(.horizontal, 12)
                        .accessibilityLabel(Text("Selected", bundle: .core))
                        .hidden(!viewModel.selectedRecipients.contains(viewModel.allRecipient))
                }
            })
            .padding(16)
            separator
        }
    }
}
