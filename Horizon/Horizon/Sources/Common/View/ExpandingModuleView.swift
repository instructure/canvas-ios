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

struct ExpandingModuleView: View {
    let module: HModule
    let routeToURL: (URL) -> Void
    @State private var isExpanded = false
    @State private var firstItemHeight: CGFloat = 0
    @State private var lastItemHeight: CGFloat = 0

    var body: some View {
        VStack(alignment: .leading) {
            Button {
                isExpanded.toggle()
            } label: {
                HStack(alignment: .top) {
                    ProgramCheckMarkIcon(isCompleted: module.isCompleted)
                    Size14RegularTextDarkestTitle(title: module.name.uppercased())
                    Spacer()
                    if module.isInProgress {
                        Text("INCOMPLETE ITEM", bundle: .horizon)
                            .foregroundStyle(Color.textDanger)
                            .font(.regular12)
                            .padding(5)
                            .overlay(Capsule().stroke(Color.backgroundDanger, lineWidth: 1))
                    }

                    Image(systemName: "chevron.down")
                        .tint(Color.textDark)
                        .frame(width: 18, height: 18)
                        .rotationEffect(isExpanded ? .degrees(-180) : .degrees(0))
                }
                .padding(.vertical, 16)
            }

            if isExpanded {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(module.items) { item in
                        let isFirstItem = item == module.items.first
                        let isLastItem = item == module.items.last

                        HStack {
                            moduleItemState(
                                isFirstItem: isFirstItem,
                                isLastItem: isLastItem,
                                firstItemLineHeight: firstItemHeight,
                                lastItemLineHeight: lastItemHeight,
                                isCompleted: item.isCompleted
                            )
                            moduleItemButton(item: item)
                                .readingFrame { frame in
                                    if isFirstItem { firstItemHeight = frame.height }
                                    if isLastItem { lastItemHeight = frame.height }
                                }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 23)
                }
                .padding(.bottom, 24)
            }
        }
        .padding(.horizontal, 16)
        .onFirstAppear { if module.isInProgress { isExpanded = true } }
    }

    private func moduleItemButton(item: HModuleItem) -> some View {
        Button {
            if let url = item.htmlURL {
                routeToURL(url)
            }
        } label: {
            ProgramItemView(item: item)
                .padding(.all, 12)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.backgroundLightest))
                .padding(.vertical, 10)
                .shadow(color: Color.textDark.opacity(0.2), radius: 5, x: 0, y: 0)
        }
        .disableWithOpacity(item.isLocked, disabledOpacity: 0.6)
    }

    private func moduleItemState(
        isFirstItem: Bool,
        isLastItem: Bool,
        firstItemLineHeight: CGFloat,
        lastItemLineHeight: CGFloat,
        isCompleted: Bool
    ) -> some View {
        ZStack {
            if module.isSequentialProgressRequired {
                ProgramLine(
                    isFirstItem: isFirstItem,
                    isLastItem: isLastItem,
                    firstItemLineHeight: firstItemHeight,
                    lastItemLineHeight: lastItemHeight,
                    hasMultipleItems: module.items.count > 1
                )
            }
            ZStack {
                Circle()
                    .fill(Color.backgroundLightest)
                    .frame(width: 25, height: 25)
                ProgramCheckMarkIcon(isCompleted: isCompleted)
            }

        }
    }
}

#if DEBUG
#Preview {
    ExpandingModuleView(
        module: .init(
            id: "13",
            name: "Assginemts",
            courseID: "2",
            items: [.init(id: "14", title: "Sub title 2", htmlURL: nil)]
        ),
        routeToURL: { _ in }
    )
}
#endif
