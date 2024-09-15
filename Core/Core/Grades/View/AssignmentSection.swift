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

struct AssignmentSection<Header: View, Content: View>: View {
    // MARK: - Properties
    @State private var isExpanded: Bool = false
    private let header: Header
    private let content: Content

    // MARK: - Init
    init(
        @ViewBuilder header: () -> Header,
        @ViewBuilder content: () -> Content
    ) {
        self.header = header()
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
                withAnimation {
                    isExpanded.toggle()
                }
            } label: {
                VStack(spacing: 0) {
                    headerView()
                    InstUI.Divider()
                        .padding(.horizontal, -20)
                        .accessibilityHidden(true)
                }
                .background(
                    Rectangle() // This background rectangle for removing the highlighted last section in list it's coming by default in the List
                        .fill(Color.backgroundLightest)
                        .padding(.horizontal, -20)
                        .padding(.top, -10)
                        .padding(.bottom, -4)
                        .accessibilityHidden(true)
                )
                .accessibilityHint(isExpanded
                                   ? String(localized: "Double Tap to collapse section", bundle: .core)
                                   : String(localized: "Double Tap to expand section", bundle: .core)
                )
            }
        }
    }

    @ViewBuilder
    private func headerView() -> some View {
        HStack {
            header
            Spacer()
            Image.arrowOpenUpLine
                .size(16)
                .rotationEffect(isExpanded ? .degrees(0) : .degrees(-180))
                .accessibilityHidden(true)
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
