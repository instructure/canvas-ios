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

public struct RecipientPillView: View {

    private let recipient: Recipient
    private var removeDidTap: (Recipient) -> Void

    public init(recipient: Recipient, removeDidTap: @escaping (Recipient) -> Void) {
        self.recipient = recipient
        self.removeDidTap = removeDidTap
    }

    public var body: some View {
        Button {
            // Pill component's remove button combined with the Wrapping Hstack works only with this extra button
        } label: {
            HStack(spacing: 0) {
                Avatar(name: recipient.displayName, url: recipient.avatarURL, size: 26)
                    .padding(.trailing, 10)
                Text(recipient.displayName)
                    .font(.regular14)
                    .foregroundColor(.textDark)
                    .padding(.trailing, 10)
                    .truncationMode(.tail)
                    .lineLimit(1)
                removeButton
                    .padding(.trailing, 10)
            }
            .padding(5)
            .overlay(
                RoundedRectangle(cornerRadius: 100)
                    .stroke(Color.textDark, lineWidth: 0.5)
            )
        }
        .font(.regular12)
        .foregroundColor(.textDarkest)
        .accessibilityElement(children: .ignore)
        .accessibility(label: Text(recipient.displayName))
        .accessibilityAction(named: Text("Remove recipient", bundle: .core)) {
            removeDidTap(recipient)
        }
    }

    private var removeButton: some View {
        Button {
            removeDidTap(recipient)
        } label: {
            Image.xLine
                .frame(width: 9, height: 9)
                .foregroundColor(.textDark)
                .padding(.horizontal, 2)
        }
    }
}

#if DEBUG

struct RecipientPillView_Previews: PreviewProvider {
    static let context = PreviewEnvironment().globalDatabase.viewContext

    static var previews: some View {
        RecipientPillView(recipient:
                .init(id: "1", name: "Student With Extremely Long FirstName and Surname To Check TextFields", avatarURL: nil), removeDidTap: { _ in })
    }
}

#endif
