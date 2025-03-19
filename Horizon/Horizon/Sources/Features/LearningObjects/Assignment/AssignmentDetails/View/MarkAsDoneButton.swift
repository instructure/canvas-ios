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
import HorizonUI

struct MarkAsDoneButton: View {
    let isCompleted: Bool
    let isLoading: Bool
    let onTap: () -> Void

    var body: some View {
        let text = isCompleted
        ? AssignmentLocalizedKeys.done.title
        : AssignmentLocalizedKeys.markAsDone.title

        let image = isCompleted
        ? Image.huiIcons.checkBox
        : Image.huiIcons.checkBoxOutlineBlank

        HStack(spacing: .huiSpaces.space10) {
            Spacer()
            if isLoading {
                HorizonUI.Spinner(size: .xSmall, showBackground: false)
                    .padding(.horizontal, .huiSpaces.space24)
                    .padding(.vertical, .huiSpaces.space10)
                    .background {
                        Capsule()
                            .fill( Color.huiColors.surface.pagePrimary)
                    }
            } else {
                HorizonUI.PrimaryButton(
                    text,
                    type: .beige,
                    leading: image
                ) {
                    onTap()
                }
            }
        }
        .animation(.smooth, value: [isCompleted, isLoading])
    }
}

#Preview {
    MarkAsDoneButton(
        isCompleted: true,
        isLoading: true
    ) {}
        .padding()
}
