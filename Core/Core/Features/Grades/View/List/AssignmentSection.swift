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

import SwiftUI

struct AssignmentSection<Content: View>: View {

    // MARK: - Properties
    @State private var isExpanded: Bool = true
    private let title: String
    private let titleA11yLabel: String
    private let content: Content

    // MARK: - Init
    init(
        title: String,
        titleA11yLabel: String,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.titleA11yLabel = titleA11yLabel
        self.content = content()
    }

    // MARK: - Body
    var body: some View {
        Section {
            if isExpanded {
                content
            }
        } header: {
            Button {
                isExpanded.toggle()
            } label: {
                VStack(spacing: 0) {
                    headerView()
                        .paddingStyle(.trailing, .standard)
                    InstUI.Divider()
                        .accessibilityHidden(true)
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityHint(isExpanded
                               ? String(localized: "expanded", bundle: .core)
                               : String(localized: "collapsed", bundle: .core)
            )
            .background(Color.backgroundLightest)
        }
    }

    @ViewBuilder
    private func headerView() -> some View {
        HStack {
            Text(title)
                .foregroundStyle(Color.textDark)
                .font(.semibold14)
                .frame(maxWidth: .infinity, minHeight: 40, alignment: .leading)
                .frame(height: 40)
                .paddingStyle(.horizontal, .standard)
                .accessibilityLabel(titleA11yLabel)
            Spacer()
            Image.arrowOpenUpLine
                .size(16)
                .rotationEffect(isExpanded ? .degrees(0) : .degrees(-180))
                .accessibilityHidden(true)
                .animation(.smooth, value: isExpanded)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isExpanded.toggle()
        }
    }
}

extension AssignmentSection: Equatable {

    static func == (lhs: AssignmentSection<Content>, rhs: AssignmentSection<Content>) -> Bool {
        lhs.title == rhs.title && lhs.titleA11yLabel == rhs.titleA11yLabel
    }
}
