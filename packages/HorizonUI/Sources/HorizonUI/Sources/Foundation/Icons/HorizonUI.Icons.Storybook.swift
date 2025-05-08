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
        private let icons: [IconsModel] = IconsModel.icons

        public var body: some View {
            ScrollView {
                VStack {
                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: 20), spacing: 16)],
                        alignment: .leading,
                        spacing: 16
                    ) {
                        ForEach(icons) { item in
                            item.image
                        }
                    }
                }
                .padding(16)
            }
            .navigationTitle("Icons")
        }
    }
}

fileprivate extension HorizonUI.Icons.Storybook {
    struct IconsModel: Identifiable {
        let id = UUID()
        let image: Image

        static var icons: [Self] {
            Image.huiIcons.allImages().map { .init(image: $0) }
        }
    }
}
