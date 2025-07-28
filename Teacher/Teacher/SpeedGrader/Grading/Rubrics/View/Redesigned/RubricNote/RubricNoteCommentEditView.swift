//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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
import Core

struct RubricNoteCommentEditView: View {

    @State private var text: String
    private var onSendTapped: (String) -> Void

    init(comment: String, onSendTapped: @escaping (String) -> Void) {
        self._text = .init(initialValue: comment)
        self.onSendTapped = onSendTapped
    }

    @ScaledMetric private var uiScale: CGFloat = 1

    var body: some View {
        TextField("Note", text: $text, axis: .vertical)
            .textFieldStyle(.plain)
            .font(.regular14)
            .lineLimit(3)
            .padding(.leading, 13)
            .padding(.trailing, 30 * uiScale)
            .padding(.vertical, 8)
            .overlay(alignment: .bottomTrailing) {
                Button(
                    action: {
                        onSendTapped(text)
                    }
                ) {

                    let image = Image
                        .circleArrowUpSolid
                        .scaledIcon(size: 24)

                    if text.isEmpty {
                        image.foregroundStyle(Color.disabledGray)
                    } else {
                        image.foregroundStyle(.tint)
                    }
                }
                .padding(.trailing, 4)
                .padding(.bottom, 4)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.borderMedium, lineWidth: 0.5)
                    .frame(minHeight: 32)
            }
            .padding(.trailing, 16)
    }
}
