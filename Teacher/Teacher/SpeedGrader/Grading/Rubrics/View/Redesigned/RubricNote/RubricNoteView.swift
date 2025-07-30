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

struct RubricNoteView: View {

    let comment: String?
    let updated: (String) -> Void

    @State private var isEditFieldShown: Bool = false
    @FocusState private var isEditFieldFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Rubric Note")
                .font(.semibold14)
                .foregroundStyle(Color.textDark)

            if let comment, comment.isNotEmpty, !isEditFieldShown {
                RubricNoteCommentBubbleView(comment: comment) {
                    isEditFieldShown = true
                    isEditFieldFocused = true
                }
            } else {
                RubricNoteCommentEditView(comment: comment ?? "") { newComment in
                    updated(newComment.trimmed())
                    isEditFieldShown = false
                    isEditFieldFocused = false
                }
                .focused($isEditFieldFocused)
                .paddingStyle(.trailing, .standard)
                .onChange(of: isEditFieldFocused) { _, newValue in
                    if newValue == false {
                        isEditFieldShown = false
                    }
                }
            }
        }
        .padding(.top, 8)
        .padding(.leading, 16)
        .padding(.bottom, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .top) {
            InstUI.Divider()
        }
    }
}

#if DEBUG

struct RubricNoteView_Previews: PreviewProvider {

    @State private static var userComment: String? = "Hello, World!"

    static var previews: some View {
        RubricNoteView(comment: userComment) { newComment in
            userComment = newComment
        }
    }
}

#endif
