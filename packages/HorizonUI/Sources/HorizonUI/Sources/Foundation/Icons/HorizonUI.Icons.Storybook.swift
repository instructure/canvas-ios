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

public extension HorizonUI.Icons {
    struct Storybook: View {
        @State private var imagePresented: [UUID: Bool] = {
            var dict = [UUID: Bool]()
            IconsModel.icons.forEach { dict[$0.id] = false }
            return dict
        }()
        private let icons: [IconsModel] = IconsModel.icons

        public var body: some View {
            ScrollView {
                VStack {
                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: 20), spacing: 16)],
                        alignment: .leading,
                        spacing: 16
                    ) {
                        ForEach(icons, content: buildIcon)
                    }
                }
                .padding(16)
            }
            .navigationTitle("Icons")
        }

        private func buildIcon(_ icon: IconsModel) -> some View {
            icon.image
                .onTapGesture { imagePresented[icon.id] = true }
                .huiTooltip(isPresented:
                    Binding(
                        get: { imagePresented[icon.id] ?? false },
                        set: { newValue in imagePresented[icon.id] = newValue }
                    )
                ) {
                    Text(icon.label ?? "No label")
                }
        }
    }
}

fileprivate extension HorizonUI.Icons.Storybook {
    struct IconsModel: Identifiable {
        let id = UUID()
        let image: Image
        let label: String?

        static var icons: [Self] {
            Image.huiIcons.allImages().map { .init(image: $0.image!, label: $0.label) }
        }
    }
}
