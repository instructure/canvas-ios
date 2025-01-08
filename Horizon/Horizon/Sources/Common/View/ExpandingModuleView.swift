//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

import Core
import SwiftUI
import HorizonUI

struct ExpandingModuleView: View {
    let module: HModule
    let routeToURL: (URL) -> Void
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            header

            if isExpanded {
                Divider()
                    .background(Color.huiColors.lineAndBorders.lineStroke)
                    .padding(.bottom, .huiSpaces.primitives.mediumSmall)

                expandedContent
                    .padding(.bottom, .huiSpaces.primitives.large)
            }
        }
        .animation(.smooth, value: isExpanded)
        .onFirstAppear { if module.isInProgress { isExpanded = true } }
    }

    private var header: some View {
        Button(action: toggleExpansion) {
            HorizonUI.ModuleContainer(
                title: module.name,
                numberOfItems: module.items.count,
                numberOfPastDueItems: module.dueItemsCount,
                duration: "76 mins", // TODO: Set actual value
                isCompleted: module.isCompleted,
                isCollapsed: isExpanded
            )
        }
    }

    private var expandedContent: some View {
        VStack(alignment: .leading, spacing: .huiSpaces.primitives.xSmall) {
            ForEach(module.items) { item in
                if let type = item.type {
                    moduleItemRow(for: item, type: type)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, .huiSpaces.primitives.mediumSmall)
        }
    }

    private func moduleItemRow(for item: HModuleItem, type: ModuleItemType) -> some View {
        HStack(spacing: .huiSpaces.primitives.xSmall) {
//            completedImage(isCompleted: item.isCompleted)
//                .foregroundStyle(Color.huiColors.surface.institution)

            moduleItemButton(item: item, type: type)
        }
    }

//    private func completedImage(isCompleted: Bool) -> some View {
//        isCompleted ? Image.huiIcons.checkCircleFull : Image.huiIcons.radioButtonUnchecked
//    }

    private func moduleItemButton(item: HModuleItem, type: ModuleItemType) -> some View {
        Button(action: { handleItemTap(item) }) {
            if let itemType = HorizonUI.ModuleItemCard.ItemType(rawValue: type.assetType.rawValue) {
                HorizonUI.ModuleItemCard(
                    name: item.title,
                    type: itemType,
                    duration: "20 Mins", // TODO: Set correct value
                    dueDate: item.dueAt?.dateOnlyString,
                    points: item.points,
                    isOverdue: item.isOverDue
                )
            }
        }
        .disableWithOpacity(item.isLocked, disabledOpacity: 0.6)
    }

    private func toggleExpansion() {
        isExpanded.toggle()
    }

    private func handleItemTap(_ item: HModuleItem) {
        if let url = item.htmlURL {
            routeToURL(url)
        }
    }
}

#Preview {
    ExpandingModuleView(
        module: .init(
            id: "13",
            name: "Assignments",
            courseID: "2",
            items: [.init(id: "14", title: "Sub title 2", htmlURL: nil)]
        ),
        routeToURL: { _ in }
    )
}
