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

public struct MessageView: View {
    private var model: MessageViewModel

    public init(model: MessageViewModel) {
        self.model = model
    }

    public var body: some View {
        VStack {
            headerView
            bodyView
            Button(action: reply, label: {
                Text("Reply")
                    .font(.medium16)
                    .foregroundColor(Color(Brand.shared.linkColor))
            })
        }
    }

    private var headerView: some View {
        HStack {
            Avatar(name: model.avatarName, url: model.avatarURL)
                .frame(width: 36, height: 36)
                .padding(.top, 5)
            VStack(alignment: .leading) {
                Text(model.author)
                    .font(.regular16)
                Text(model.date)
                    .font(.regular14)
            }
            Button(action: reply, label: {
                Image
                    .replyLine
                    .size(15)
                    .foregroundColor(.textDark)
                    .padding(.leading, 6)
                    .accessibilityHidden(true)

            })
            Button(action: more, label: {
                Image
                    .moreLine
                    .size(15)
                    .foregroundColor(.textDark)
                    .padding(.leading, 6)
                    .accessibilityHidden(true)

            })
        }
    }

    private var bodyView: some View {
        Text(model.body)
            .font(.regular16)
        //Attachments
    }

    private func reply() {

    }

    private func more() {

    }
}
