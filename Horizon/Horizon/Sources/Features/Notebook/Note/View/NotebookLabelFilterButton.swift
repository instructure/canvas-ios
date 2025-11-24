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

import HorizonUI
import SwiftUI

struct NotebookLabelFilterButton: View {
    @State private var isListLableVisiable = false
    private let list: [CourseNoteLabel] = [.important, .unclear]

    // MARK: - Dependencies

    private let selectedLabel: CourseNoteLabel
    private let onTap: (CourseNoteLabel) -> Void

    // MARK: - Init

    init(
        selectedLabel: CourseNoteLabel,
        onTap: @escaping (CourseNoteLabel) -> Void
    ) {
        self.selectedLabel = selectedLabel
        self.onTap = onTap
    }

    var body: some View {
        Button {
            isListLableVisiable.toggle()
        } label: {
            labelButton
        }
        .accessibilityHint(
                    Text(
                        String.localizedStringWithFormat(
                            String(localized: "Selected notebook label is %@. Double tap to select another lable", bundle: .horizon),
                            selectedLabel.label
                        )
                    )
                )
        .popover(isPresented: $isListLableVisiable, attachmentAnchor: .point(.center), arrowEdge: .top) {
            listLabelView
                .presentationCompactAdaptation(.none)
                .presentationBackground(Color.huiColors.surface.cardPrimary)
        }
        .accessibilityRemoveTraits(.isButton)
    }

    private var labelButton: some View {
        HStack(spacing: .huiSpaces.space2) {
            selectedLabel.image
                .foregroundStyle(selectedLabel.color)
                .accessibilityHidden(true)
            Text(selectedLabel.label)
                .foregroundStyle(selectedLabel.color)
                .huiTypography(.p2)
            Image.huiIcons.keyboardArrowDown
                .foregroundStyle(selectedLabel.color)
                .rotationEffect(.degrees(isListLableVisiable ? 180 : 0))
                .animation(.easeInOut, value: isListLableVisiable)
                .frame(width: 24, height: 24)
                .accessibilityHidden(true)
        }
        .padding(.vertical, .huiSpaces.space4)
        .padding(.horizontal, .huiSpaces.space8)
        .huiBorder(level: .level1, color: selectedLabel.color, radius: 8)
    }

    private var listLabelView: some View {
        VStack(alignment: .leading, spacing: .zero) {
            ForEach(list, id: \.self) { label in
                Button {
                    onTap(label)
                    isListLableVisiable.toggle()
                } label: {
                    NotebookLabelView(
                        label: label,
                        isSelected: label == selectedLabel
                    )
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var selectedLabel = CourseNoteLabel.important
    VStack {
        NotebookLabelFilterButton(selectedLabel: selectedLabel) { label in
            selectedLabel = label
        }
    }
}

private struct NotebookLabelView: View {
    let label: CourseNoteLabel
    let isSelected: Bool
    var body: some View {
        HStack(spacing: .huiSpaces.space4) {
            label.image
            Text(label.markNoteName)
            Spacer()

        }
        .frame(minWidth: 160, minHeight: 55)
        .padding(.leading, .huiSpaces.space12)
        .foregroundStyle(isSelected ? label.color : Color.huiColors.text.body)
        .background(isSelected ? label.backgroundColor : Color.clear)
        .fixedSize(horizontal: true, vertical: false)
    }
}
