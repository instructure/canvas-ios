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

struct SelectionPopover: View {
    let items: [DropdownMenuItem]
    let selectedItem: DropdownMenuItem?
    let onSelect: (DropdownMenuItem) -> Void
    @State private var isListVisiable = false
    var body: some View {
        DropDownButton(status: selectedItem?.name ?? "") {
            isListVisiable.toggle()
        }
        .popover(isPresented: $isListVisiable, attachmentAnchor: .point(.center), arrowEdge: .top) {
            listView
                .presentationCompactAdaptation(.none)
                .presentationBackground(Color.huiColors.surface.cardPrimary)
        }
    }

    private var listView: some View {
        ScrollView {
            VStack(spacing: .zero) {
                ForEach(items) { item in
                    Button {
                        onSelect(item)
                        isListVisiable.toggle()
                    } label: {
                        TimeSpentCourseView(
                            name: item.name,
                            isSelected: item == selectedItem
                        )
                    }
                }
            }
        }
    }
}
