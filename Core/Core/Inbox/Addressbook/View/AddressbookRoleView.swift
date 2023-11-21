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
                rolesView
            case .empty, .error:
                Text("There was an error loading recipients.", bundle: .core)
                    .frame(maxWidth: .infinity)
            }
        }
        .background(Color.backgroundLightest)
        .navigationTitle(viewModel.title)
    }

    private var loadingIndicator: some View {
        ProgressView()
            .progressViewStyle(.indeterminateCircle())
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .accentColor(Color(Brand.shared.primary))
    }

    private var separator: some View {
        Color.borderMedium
            .frame(height: 0.5)
    }

    private var rolesView: some View {
        VStack(alignment: .leading, spacing: 0) {
            separator
            allRecipient
            ForEach(viewModel.roles, id: \.self) { role in
                roleRowView(role)
            }
        }
    }

    private func roleRowView(_ role: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: {
                viewModel.recipientDidTap.send((roleName: role, recipient: viewModel.roleRecipients[role] ?? [], controller: controller))
            }, label: {
                HStack(alignment: .center, spacing: 16) {
                    Avatar(name: role, url: nil, size: 36, isAccessible: false)
                    VStack(alignment: .leading) {
                        Text(role)
                            .font(.regular16)
                            .foregroundColor(.textDarkest)
                            .lineLimit(1)
                        Text("\(viewModel.roleRecipients[role]?.count ?? 0) People", bundle: .core)
                            .font(.regular14)
                            .foregroundColor(.textDark)
                            .lineLimit(1)
                    }
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
                        Text("All in \(viewModel.recipientContext.name)", bundle: .core)
                            .font(.regular16)
                            .foregroundColor(.textDarkest)
                            .lineLimit(1)
                        Text("\(viewModel.recipients.count) People", bundle: .core)
                            .font(.regular14)
                            .foregroundColor(.textDark)
                            .lineLimit(1)
                    }
                }
            })
            .padding(16)
            separator
        }
    }
}
