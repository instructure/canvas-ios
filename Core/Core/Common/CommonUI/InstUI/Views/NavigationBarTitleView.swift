//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

<<<<<<<< HEAD:packages/HorizonUI/Sources/HorizonUI/Sources/Components/Cards/HorizonUI.Card.Stroybook.swift
public extension HorizonUI.Cards {
    struct Storybook: View {
        public var body: some View {
            ScrollView {
                VStack {
                    Text("Module Container")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    HorizonUI.ModuleContainer.Storybook()
                    Text("Module Item Card")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    HorizonUI.LearningObjectItem.Storybook()
                    Text("Learning Object Card")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    HorizonUI.LearningObjectCard.Storybook()
                }
            }
            .navigationTitle("Cards")
            .padding()
            .background(Color.black.opacity(0.1))
        }
    }
}

#Preview {
    HorizonUI.Cards.Storybook()
}

public extension HorizonUI {
    struct Cards { }
}
========
extension InstUI {

    public struct NavigationBarTitleView: View {
        @Environment(\.dynamicTypeSize) private var dynamicTypeSize
        @Environment(\.navBarColors) private var navBarColors

        private let title: String
        private let subtitle: String?

        public init(
            title: String,
            subtitle: String? = nil
        ) {
            self.title = title
            self.subtitle = subtitle
        }

        public var body: some View {
            VStack(spacing: 1) {
                Text(title)
                    .font(.semibold16)
                    .foregroundColor(navBarColors.title)

                if let subtitle, subtitle.isNotEmpty {
                    Text(subtitle)
                        .font(.regular14)
                        .foregroundColor(navBarColors.subtitle)
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isHeader)
        }
    }
}
>>>>>>>> origin/master:Core/Core/Common/CommonUI/InstUI/Views/NavigationBarTitleView.swift
