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
    // MARK: - Dependencies

    let module: HModule
    let routeToURL: (URL) -> Void
    @State private(set) var isExpanded = false

    init(module: HModule, isExpanded: Bool = false, routeToURL: @escaping (URL) -> Void) {
        self.module = module
        self.routeToURL = routeToURL
        self._isExpanded = State(initialValue: isExpanded)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            header
            if isExpanded {
                Divider()
                    .background(Color.huiColors.lineAndBorders.lineStroke)
                    .padding(.bottom, .huiSpaces.space16)

                ModuleItemListView(items: module.items) { selectedItem in
                    handleItemTap(selectedItem)
                }
                .padding([.horizontal, .bottom], .huiSpaces.space16)
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
                duration: module.estimatedDurationFormatted,
                isCollapsed: isExpanded)
        }
        .buttonStyle(.plain)
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

#Preview("Expanded") {
    ExpandingModuleView(
        module: .init(
            id: "13",
            name: "Assignments",
            courseID: "2",
            items: [.init(id: "14", title: "Sub title 2", htmlURL: nil)]
        ),
        isExpanded: true,
        routeToURL: { _ in }
    )
}
