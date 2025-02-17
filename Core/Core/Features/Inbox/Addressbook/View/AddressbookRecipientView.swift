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

public struct AddressbookRecipientView: View, ScreenViewTrackable {
    @ObservedObject private var viewModel: AddressbookRecipientViewModel
    @Environment(\.viewController) private var controller
    public let screenViewTrackingParameters: ScreenViewTrackingParameters

    init(model: AddressbookRecipientViewModel) {
        self.viewModel = model

        screenViewTrackingParameters = ScreenViewTrackingParameters(
            eventName: "/conversations/compose/addressbook/recipients"
        )
    }

    public var body: some View {
        ScrollView {
            listView
        }
        .searchable(
            text: Binding { viewModel.searchText.value } set: { viewModel.searchText.send($0) },
            placement: .navigationBarDrawer(displayMode: .always)
        )
        .background(Color.backgroundLightest)
        .navigationTitle(viewModel.title)
        .navigationBarItems(trailing: doneButton)
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
        .accessibilityIdentifier("Inbox.addRecipient.done")
    }

    private var listView: some View {
        VStack(alignment: .leading, spacing: 0) {
            if viewModel.isAllRecipientButtonVisible {
                allRecipientsRow
            }
            ForEach(viewModel.recipients, id: \.self) { user in
                recipientRow(user)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(String.localizedAccessibilityListCount(viewModel.listCount))
    }

    private func recipientRow(_ recipient: Recipient) -> some View {
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
                        .accessibilityIdentifier("ComposeMessage.recipient.\(recipient.ids.first ?? "all\(recipient.displayName)")")
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

    private var allRecipientsRow: some View {
            VStack(alignment: .leading, spacing: 0) {
                Button(action: {
                    viewModel.recipientDidTap.send(viewModel.allRecipient)
                }, label: {
                    HStack(alignment: .center, spacing: 16) {
                        Avatar(name: String(localized: "All", bundle: .core), url: nil, size: 36, isAccessible: false)
                        VStack(alignment: .leading, spacing: 8) {
                            Text(viewModel.allRecipient.displayName)
                                .font(.regular16)
                                .foregroundColor(.textDarkest)
                                .lineLimit(1)
                                .accessibilityIdentifier("ComposeMessage.recipient.all\(viewModel.roleName)")
                            Text("\(viewModel.allRecipient.ids.count) People", bundle: .core)
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

#if DEBUG

struct AddressbookRecipientView_Previews: PreviewProvider {
    static let env = PreviewEnvironment()

    static var previews: some View {
        AddressBookAssembly.makePreview(env: env)
    }
}

#endif
