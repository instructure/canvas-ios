//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

public extension InstUI {
    struct Storybook: View {
        public init() {}

        public var body: some View {
            List {
                Section(header: Text(verbatim: "Semantic")) {
                    StorybookItem("Color") { InstUI.Semantic.Color.Storybook() }
                    StorybookItem("Size") { InstUI.Semantic.Size.Storybook() }
                    StorybookItem("Spacing") { InstUI.Semantic.Spacing.Storybook() }
                    StorybookItem("Border Radius") { InstUI.Semantic.BorderRadius.Storybook() }
                    StorybookItem("Border Width") { InstUI.Semantic.BorderWidth.Storybook() }
                    StorybookItem("Font Size") { InstUI.Semantic.FontSize.Storybook() }
                    StorybookItem("Opacity") { InstUI.Semantic.Opacity.Storybook() }
                    StorybookItem("Font Weight") { InstUI.Semantic.FontWeight.Storybook() }
                    StorybookItem("Font Family") { InstUI.Semantic.FontFamily.Storybook() }
                }
                Section(header: Text(verbatim: "Primitive")) {
                    StorybookItem("Color") { InstUI.Primitive.Color.Storybook() }
                    StorybookItem("Opacity") { InstUI.Primitive.Opacity.Storybook() }
                    StorybookItem("Size") { InstUI.Primitive.Size.Storybook() }
                    StorybookItem("Font Weight") { InstUI.Primitive.FontWeight.Storybook() }
                    StorybookItem("Font Family") { InstUI.Primitive.FontFamily.Storybook() }
                }
            }
            .listStyle(.sidebar)
            .navigationTitle(Text(verbatim: "InstUI"))
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

private struct StorybookItem<Destination: View>: View {
    private let label: String
    private let destination: Destination

    init(
        _ label: String,
        @ViewBuilder destination: () -> Destination
    ) {
        self.label = label
        self.destination = destination()
    }

    var body: some View {
        NavigationLink {
            destination
        } label: {
            Text(verbatim: label)
        }
    }
}

#Preview {
    NavigationStack {
        InstUI.Storybook()
    }
}
