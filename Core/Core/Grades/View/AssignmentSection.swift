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

struct AssignmentSection<Label: View, Content: View>: View {
    // MARK: - Properties
    @State private var isExpanded: Bool = true
    private let label: Label
    private let content: Content

    // MARK: - Init
    init(@ViewBuilder label: () -> Label, @ViewBuilder content: () -> Content) {
        self.label = label()
        self.content = content()
    }
    // MARK: - Body
    var body: some View {
        Section {
            if isExpanded {
                content
            }
        } header: {
            VStack {
                headerView()
                InstUI.Divider()
                    .padding(.horizontal, -20)
                    .accessibilityHidden(true)
            }
        }
        .padding(.vertical, -7) // To minimize the spacing between sections in the list
        .background {
            Rectangle()
                .fill(Color.backgroundLightest)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .padding(.horizontal, -20)
        }
    }

    @ViewBuilder
    private func headerView() -> some View {
        HStack {
            label
            Spacer()
            Image.arrowOpenUpLine
                .size(16)
                .rotationEffect(isExpanded ? .degrees(0) : .degrees(-180))
                .accessibilityHidden(true)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation {
                isExpanded.toggle()
            }
        }
    }
}

#if DEBUG
#Preview {
    AssignmentSection {
        Text(verbatim: "Header")
    } content: {
        Text(verbatim: "Item 1")
            .frame(maxWidth: .infinity, alignment: .leading)
        Text(verbatim: "Item 2")
            .frame(maxWidth: .infinity, alignment: .leading)
        Text(verbatim: "Item 3")
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
#endif
