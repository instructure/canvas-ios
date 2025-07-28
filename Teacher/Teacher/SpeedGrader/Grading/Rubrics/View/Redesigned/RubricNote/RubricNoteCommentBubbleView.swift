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

struct RubricNoteCommentBubbleView: View {

    let comment: String
    let onEdit: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            Text(comment)
                .font(.regular14)
                .foregroundStyle(Color.textDarkest)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(8)
                .background(Color.backgroundLight)
                .cornerRadius(16)
            Button(action: onEdit) {
                Image
                    .editLine
                    .scaledIcon(size: 24)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
            }
            .tint(.textDark)
        }
    }
}
