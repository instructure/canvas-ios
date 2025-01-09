//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

public struct GroupContextCardView: View {
    @Environment(\.viewController) private var controller
    @ObservedObject private var model: GroupContextCardViewModel

    public init(model: GroupContextCardViewModel) {
        self.model = model
    }

    public var body: some View {
        contextCard
            .navigationBarItems(trailing: emailButton)
            .navigationTitle(model.user.first?.name ?? "", subtitle: model.group.first?.name)
            .onAppear {
                model.viewAppeared()
            }
    }

    @ViewBuilder var emailButton: some View {
        if model.shouldShowMessageButton {
            Button(action: { model.openNewMessageComposer(controller: controller.value) }, label: {
                Image.emailLine
                    .foregroundColor(Color(Brand.shared.navTextColor))
            })
            .accessibility(label: Text("Send message", bundle: .core))
            .identifier("ContextCard.emailContact")
        }
    }

    @ViewBuilder var contextCard: some View {
        if model.pending {
            ProgressView()
                .progressViewStyle(.indeterminateCircle())
        } else {
            if let user = model.user.first, let group = model.group.first {
                VStack(spacing: 10) {
                    Avatar(name: user.name, url: user.avatarURL, size: 80)
                        .padding(20)
                    Text(User.displayName(user.shortName, pronouns: user.pronouns))
                        .font(.bold20)
                        .foregroundColor(.textDarkest)
                        .identifier("ContextCard.userNameLabel")
                    ZStack {
                        Divider()
                        VStack {
                            Text(group.name)
                                .font(.semibold16)
                                .identifier("ContextCard.groupLabel")
                        }
                        .padding(.horizontal, 16).padding(.vertical, 8)
                        .background(RoundedRectangle(cornerRadius: 4).stroke(Color.borderDarkest, lineWidth: 1 / UIScreen.main.scale))
                        .foregroundColor(.textDarkest)
                        .background(Color.backgroundLightest)
                    }
                    Spacer()
                }
                .padding(.vertical, 16)
                .onAppear {
                    UIAccessibility.post(notification: .screenChanged, argument: nil)
                }
            } else {
                EmptyPanda(.Unsupported, title: Text("Something went wrong", bundle: .core), message: Text("There was an error while communicating with the server", bundle: .core))
            }
        }
    }
}
