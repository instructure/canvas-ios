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
import HorizonUI

struct ModuleItemListView: View {
    // MARK: - Dependencies

    @State var selectedModuleItem: HModuleItem?
    let items: [HModuleItem]
    let onSelectItem: (HModuleItem) -> Void

    init(
        selectedModuleItem: HModuleItem? = nil,
        items: [HModuleItem],
        onSelectItem: @escaping (HModuleItem) -> Void
    ) {
        self.selectedModuleItem = selectedModuleItem
        self.items = items
        self.onSelectItem = onSelectItem
    }

    var body: some View {
        VStack(alignment: .leading, spacing: .huiSpaces.space8) {
            ForEach(items) { item in
                if let type = item.type {
                    if type == .subHeader {
                        subHeaderText(for: item)
                    } else {
                        moduleItemButton(item: item, type: type)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func subHeaderText(for item: HModuleItem) -> some View {
        Text(item.title)
            .huiTypography(.labelMediumBold)
            .foregroundStyle(Color.huiColors.text.body)
            .padding(.top, items.first?.id == item.id ? .zero : .huiSpaces.space32)
    }

    private func moduleItemButton(item: HModuleItem, type: ModuleItemType) -> some View {
        Button(action: { handleItemTap(item) }) {
            if let itemType = HorizonUI.LearningObjectItem.ItemType(rawValue: type.assetType.rawValue) {
                HorizonUI.LearningObjectItem(
                    name: item.title,
                    isSelected: selectedModuleItem == item,
                    requirement: item.isOptional ? .optional : .required,
                    status: item.status,
                    type: item.isQuizLTI ? .assessment : itemType,
                    duration: item.estimatedDurationFormatted,
                    dueDate: item.dueAt?.dateOnlyString,
                    lockedMessage: item.lockedMessage,
                    points: item.points?.trimmedString,
                    description: item.statusDescription,
                    isOverdue: item.isOverDue
                )
            }
        }
        .buttonStyle(.plain)
    }

    private func handleItemTap(_ item: HModuleItem) {
        selectedModuleItem = item
        onSelectItem(item)
    }
}

#Preview {
    let moduleItems: [HModuleItem] =
    [
        .init(id: "10", title: "AI Section", htmlURL: nil, type: .file("")),
        .init(id: "12", title: "AI Section Demo", htmlURL: nil, type: .file(""))
    ]
    ModuleItemListView(selectedModuleItem: moduleItems.first, items: moduleItems) { _ in }
}
