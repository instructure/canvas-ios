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

struct OptionModel: Identifiable, Equatable {
    let id: Int
    let name: String
}

struct FilterView: View {
    @State private var isListVisiable = false

    // MARK: - Dependencies

    private let items: [OptionModel]
    private let selectedOption: OptionModel?
    private let onSelect: (OptionModel?) -> Void

    // MARK: - Init

    init(
        items: [OptionModel],
        selectedOption: OptionModel?,
        onSelect: @escaping (OptionModel?) -> Void
    ) {
        self.items = items
        self.selectedOption = selectedOption
        self.onSelect = onSelect

    }

    var body: some View {
        courseSelectionView
            .frame(maxWidth: 200)
            .fixedSize(horizontal: true, vertical: false)
    }

    private var courseSelectionView: some View {
        CourseSelectionButton(status: selectedOption?.name ?? "") {
            isListVisiable.toggle()
        }
        .frame(minWidth: 130)
        .accessibilityHint(
            Text(
                String.localizedStringWithFormat(
                    String(localized: "Selected filter is %@. Double tap to select another filter. %@", bundle: .horizon),
                    selectedOption?.name ?? "",
                    isListVisiable ? String(localized: "Expanded") : String(localized: "Collapsed")
                )
            )
        )
        .popover(isPresented: $isListVisiable, attachmentAnchor: .point(.center), arrowEdge: .top) {
            courseListView
                .presentationCompactAdaptation(.none)
                .presentationBackground(Color.huiColors.surface.cardPrimary)
        }
        .accessibilityRemoveTraits(.isButton)
    }

    private var courseListView: some View {
        ScrollView {
            VStack(spacing: .zero) {
                ForEach(items) { status in
                    Button {
                        onSelect(status)
                        isListVisiable.toggle()
                    } label: {
                        TimeSpentCourseView(
                            name: status.name,
                            isSelected: status == selectedOption
                        )
                    }
                    .accessibilityAddTraits(status == selectedOption ? .isSelected : [])
                }
            }
            .padding(.vertical, .huiSpaces.space10)
        }
    }
}
