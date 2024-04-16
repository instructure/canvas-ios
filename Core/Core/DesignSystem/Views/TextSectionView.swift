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

public struct TextSectionView: View {
    @Environment(\.sizeCategory) private var sizeCategory
    private let title: String
    private let description: String

    init(title: String, description: String) {
        self.title = title
        self.description = description
    }

    public var body: some View {
        VStack(spacing: 0) {
            CoreDividerView()

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .textStyle(.infoTitle)
                Text(description)
                    .textStyle(.infoDescription)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .paddingStyle(.horizontal, .standard)
            .paddingStyle(.top, .paragraphTop)
            .paddingStyle(.bottom, .paragraphBottom)
        }
        .accessibilityElement(children: .combine)
    }
}

#if DEBUG

#Preview("Short Text") {
    VStack(spacing: 0) {
        TextSectionView(title: "Description",
                        description: "Not added yet...")
        TextSectionView(title: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam tincidunt rhoncus",
                        description:
                            """
                            Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam tincidunt rhoncus\
                            rutrum. Donec tempus vulputate posuere. Aenean blandit nunc vitae tempus sodales.\
                            In vehicula venenatis tempus. In pharetra aliquet neque, non viverra massa sodales eget.\
                            Etiam hendrerit tincidunt placerat. Suspendisse et lacus a metus tempor gravida.
                            New line!
                            """)
    }
}

#endif
