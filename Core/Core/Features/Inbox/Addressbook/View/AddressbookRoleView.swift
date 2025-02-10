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

struct AddressbookRoleView: View, ScreenViewTrackable {
    @ObservedObject private var viewModel: AddressbookRoleViewModel
    @Environment(\.viewController) private var controller
    @ScaledMetric private var uiScale: CGFloat = 1

    public let screenViewTrackingParameters: ScreenViewTrackingParameters

    init(model: AddressbookRoleViewModel) {
        self.viewModel = model

        screenViewTrackingParameters = ScreenViewTrackingParameters(
            eventName: "/conversations/compose/addressbook/roles"
        )
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
        .navigationBarTitleView(viewModel.title)
        .navigationBarItems(trailing: doneButton)
        .navigationBarStyle(.modal)
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
            viewModel.didTapDone.accept(controller)
        } label: {
            Text("Done", bundle: .core)
                .font(.regular16)
                .foregroundColor(.accentColor)
                .accessibilityIdentifier("Inbox.addRecipient.done")
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
                viewModel.didTapRecipient.send(recipient)
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
            if viewModel.isAllRecipientButtonVisible { allRecipient }
            ForEach(viewModel.roles, id: \.self) { role in
                roleRowView(role)
            }
        }
    }

    private func roleRowView(_ role: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: {
                viewModel.didTapRole.send((roleName: role, recipients: viewModel.roleRecipients[role] ?? [], controller: controller))
            }, label: {
                HStack(alignment: .center, spacing: 16) {
                    Avatar(name: role, url: nil, size: 36, isAccessible: false)
                    VStack(alignment: .leading, spacing: 8) {
                        Text(role)
                            .font(.regular16)
                            .foregroundColor(.textDarkest)
                            .lineLimit(1)
                            .accessibilityIdentifier("Inbox.addRecipient.all\(role)")
                        Text("\(viewModel.roleRecipients[role]?.count ?? 0) People", bundle: .core)
                            .font(.regular14)
                            .foregroundColor(.textDark)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Spacer()

                    Image.arrowOpenRightLine
                        .resizable()
                        .frame(
                            width: 15 * uiScale,
                            height: 15 * uiScale
                        )
                        .foregroundColor(.textDark)
                        .padding(.all, 12)
                }
            })
            .padding(16)
            separator
        }
    }

    private var allRecipient: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: {
                viewModel.didTapRecipient.send(viewModel.allRecipient)
            }, label: {
                HStack(alignment: .center, spacing: 16) {
                    Avatar(name: String(localized: "All", bundle: .core), url: nil, size: 36, isAccessible: false)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("All in \(viewModel.recipientContext.name)", bundle: .core)
                            .font(.regular16)
                            .foregroundColor(.textDarkest)
                            .lineLimit(1)
                            .accessibilityIdentifier("Inbox.addRecipient.allIn.\(viewModel.recipientContext.context.id)")
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
