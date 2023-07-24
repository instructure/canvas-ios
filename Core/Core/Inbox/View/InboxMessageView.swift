//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

public struct InboxMessageView: View {
    private var model: InboxMessageListItemViewModel
    private var cellDidTap: (String) -> Void

    public init(model: InboxMessageListItemViewModel, cellDidTap: @escaping (String) -> Void) {
        self.model = model
        self.cellDidTap = cellDidTap
    }

    public var body: some View {
        Button {
            cellDidTap(model.id)
        } label: {
            cellContent
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel(model.a11yLabel)
    }

    private var cellContent: some View {
        HStack(alignment: .top, spacing: 14) {
            avatar
            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(model.participantName)
                        .font(.semibold16)
                        .foregroundColor(.textDarkest)
                        .lineLimit(1)
                    Spacer()
                    Text(model.date)
                        .foregroundColor(.textDark)
                        .font(.regular12)
                }
                Text(verbatim: model.title)
                    .font(.regular14)
                    .foregroundColor(.textDarkest)
                    .lineLimit(1)
                HStack(alignment: .bottom, spacing: 0) {
                    Text(verbatim: model.message)
                        .font(.regular14)
                        .foregroundColor(.textDark)
                        .lineLimit(1)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 0)
                    attachmentIndicator
                    starredIndicator
                }
            }
        }
        .padding(.top, 12)
        .padding(.bottom, 12)
        .padding(.leading, 15)
        .padding(.trailing, 16)
        .background(Color.backgroundLightest)
        .overlay(unreadDot)
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private var avatar: some View {
        switch model.avatar {
        case .group:
            Circle()
                .strokeBorder(lineWidth: 1 / UIScreen.main.scale)
                .foregroundColor(.borderMedium)
                .overlay(Image.groupLine.foregroundColor(.borderDark))
                .frame(width: 36, height: 36)
                .padding(.top, 5)
        case .individual(let name, let profileImageURL):
            Avatar(name: name, url: profileImageURL)
                .frame(width: 36, height: 36)
                .padding(.top, 5)
        }
    }

    @ViewBuilder
    private var starredIndicator: some View {
        if model.isStarred {
            Image
                .starSolid
                .size(15)
                .foregroundColor(.textDark)
                .padding(.leading, 6)
                .accessibilityHidden(true)
        }
    }

    @ViewBuilder
    private var attachmentIndicator: some View {
        if model.hasAttachment {
            Image
                .paperclipLine
                .size(15)
                .foregroundColor(.textDarkest)
                .padding(.leading, 6)
                .accessibilityHidden(true)
        }
    }

    @ViewBuilder
    private var unreadDot: some View {
        if model.state == .unread {
            ZStack(alignment: .topLeading) {
                Circle()
                    .frame(width: 7, height: 7)
                    .foregroundColor(.electric)
                    .padding(.leading, 8)
                    .padding(.top, 13)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }
}

#if DEBUG

struct InboxMessageView_Previews: PreviewProvider {
    static let env = PreviewEnvironment()
    static let context = env.globalDatabase.viewContext

    static var previews: some View {
        InboxMessageView(model: .init(message: .make(in: context)), cellDidTap: {_ in })
            .previewLayout(.sizeThatFits)

        InboxMessageView(model: .init(message: .make(participantName: "Bob Hunter, Tray B, Joe M, Alice Swanson, Marty + 3",
                                                     in: context)), cellDidTap: {_ in })
            .previewLayout(.sizeThatFits)
    }
}

#endif
