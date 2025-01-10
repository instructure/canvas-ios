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
    @State private var selectedModuleItem: HModuleItem?

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
    }

    private var header: some View {
        Button {
            withAnimation { isExpanded.toggle() }
        } label: {
            HorizonUI.ModuleContainer(
                title: module.name,
                subtitle: module.moduleStatus.subHeader,
                status: module.moduleStatus.status,
                numberOfItems: module.contentItems.count,
                numberOfPastDueItems: module.dueItemsCount,
                duration: "76 mins", // TODO: Set actual value
                isCollapsed: isExpanded)
        }
        .buttonStyle(.plain)
    }

    private var expandedContent: some View {
        VStack(alignment: .leading, spacing: .huiSpaces.primitives.xSmall) {
            ForEach(module.items) { item in
                if let type = item.type {
                    if type == .subHeader {
                        subHeaderText(for: item)
                    } else {
                        moduleItemButton(item: item, type: type)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, .huiSpaces.primitives.mediumSmall)
        }
    }

    private func subHeaderText(for item: HModuleItem) -> some View {
        Text(item.title)
            .huiTypography(.labelMediumBold)
            .foregroundStyle(Color.huiColors.text.body)
            .padding(.top, 12)
    }

    private func moduleItemButton(item: HModuleItem, type: ModuleItemType) -> some View {
        Button(action: { handleItemTap(item) }) {
            if let itemType = HorizonUI.LearningObjectItem.ItemType(rawValue: type.assetType.rawValue) {
                HorizonUI.LearningObjectItem(
                    name: item.title,
                    isSelected: selectedModuleItem == item,
                    requirement: item.isOptional ? .optional : .required,
                    status: item.status,
                    type: itemType,
                    duration: "20 Mins", // TODO: Set correct value
                    dueDate: item.dueAt?.dateOnlyString,
                    lockedMessage: item.lockedMessage,
                    points: item.points,
                    isOverdue: item.isOverDue
                )
            }
        }
        .buttonStyle(.plain)
    }

    private func handleItemTap(_ item: HModuleItem) {
        if let url = item.htmlURL, !item.isLocked {
            routeToURL(url)
            selectedModuleItem = item
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
