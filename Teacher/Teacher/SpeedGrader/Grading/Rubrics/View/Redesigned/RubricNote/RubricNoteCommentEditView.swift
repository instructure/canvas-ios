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

    private let comment: String
    private var onSendTapped: (String) -> Void

    @ScaledMetric private var uiScale: CGFloat = 1
    @FocusState private var isFocused: Bool
    @State private var text: String

    init(
        comment: String,
        onSendTapped: @escaping (String) -> Void
    ) {
        self.comment = comment
        self.onSendTapped = onSendTapped
        self._text = .init(initialValue: comment)
    }

    var body: some View {
        TextField("Note", text: $text, axis: .vertical)
            .textFieldStyle(.plain)
            .font(.regular14)
            .lineLimit(3)
            .padding(.leading, 13)
            .padding(.trailing, 30 * uiScale)
            .padding(.vertical, 8)
            .overlay(alignment: .bottomTrailing) {
                Button(action: submitText) {
                    Image
                        .circleArrowUpSolid
                        .scaledIcon(size: 24)
                        //.foregroundStyle(.tint)
                }
                .padding(.trailing, 4)
                .padding(.bottom, 4)
                .disabled(text.isEmpty && comment.isEmpty)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.borderMedium, lineWidth: 0.5)
                    .frame(minHeight: 32)
            }
            .onSubmit(submitText)
            .focused($isFocused)
            .onFirstAppear {
                guard comment.isNotEmpty else { return }
                isFocused = true
            }
    }

    private func submitText() {
        defer { isFocused = false }
        guard comment.trimmed() != text.trimmed() else { return }
        onSendTapped(text.trimmed())
    }
}

#if DEBUG

struct RubricNoteCommentEditView_Previews: PreviewProvider {
    static var previews: some View {
        RubricNoteCommentEditView(comment: "Some Comment") { submitted in
            print(submitted)
        }
        .padding()
    }
}

#endif
