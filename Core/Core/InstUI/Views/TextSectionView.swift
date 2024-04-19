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

public extension InstUI {
    struct TextSectionView: View {
        public struct SectionData: Identifiable, Equatable {
            public var id: String { title + description }

            public let title: String
            public let description: String
            public let isRichContent: Bool

            public init(title: String, description: String, isRichContent: Bool = false) {
                self.title = title
                self.description = description
                self.isRichContent = isRichContent
            }
        }
        @Environment(\.sizeCategory) private var sizeCategory
        private let sectionData: [SectionData]

        public init(
            title: String,
            description: String,
            isRichContent: Bool = false
        ) {
            sectionData = [
                .init(title: title, description: description, isRichContent: isRichContent)
            ]
        }

        public init(_ sectionData: [SectionData]) {
            self.sectionData = sectionData
        }

        public init(_ sectionData: SectionData?) {
            self.sectionData = (sectionData == nil ? [] : [sectionData!])
        }

        @ViewBuilder
        public var body: some View {
            if sectionData.isEmpty {
                SwiftUI.EmptyView()
            } else {
                VStack(spacing: 0) {
                    InstUI.Divider()

                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(sectionData) { sectionData in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(sectionData.title)
                                    .textStyle(.infoTitle)

                                if sectionData.isRichContent {
                                    WebView(
                                        html: sectionData.description,
                                        features: [.disableDefaultBodyMargin],
                                        canToggleTheme: true
                                    )
                                    .frameToFit()
                                } else {
                                    Text(sectionData.description)
                                        .textStyle(.infoDescription)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .paddingStyle(.top, .paragraphTop)
                        }
                    }
                    .paddingStyle(.horizontal, .standard)
                    .paddingStyle(.bottom, .paragraphBottom)
                }
                .accessibilityElement(children: .combine)
            }
        }
    }
}

#if DEBUG

#Preview("Empty Array") {
    InstUI.TextSectionView([])
}

#Preview("Nil Entity") {
    InstUI.TextSectionView([])
}

#Preview("Short Text") {
    InstUI.TextSectionView(title: "Description",
                           description: "Not added yet...")
}

#Preview("Rich Content") {
    InstUI.TextSectionView([
        .init(
            title: "Rich Content",
            description: "<a href=\"\">Click here!</a>",
            isRichContent: true
        ),
        .init(
            title: "Non Rich Content Reference",
            description: "Click here!",
            isRichContent: false
        ),
    ])
}

#Preview("Long Text") {
    InstUI.TextSectionView(title: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam tincidunt rhoncus",
                           description:
                            """
                            Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam tincidunt rhoncus\
                            rutrum. Donec tempus vulputate posuere. Aenean blandit nunc vitae tempus sodales.\
                            In vehicula venenatis tempus. In pharetra aliquet neque, non viverra massa sodales eget.\
                            Etiam hendrerit tincidunt placerat. Suspendisse et lacus a metus tempor gravida.
                            New line!
                            """)
}

#Preview("Multiple Sections") {
    InstUI.TextSectionView([
        .init(
            title: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam tincidunt rhoncus",
            description: """
                         Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam tincidunt rhoncus\
                         rutrum. Donec tempus vulputate posuere. Aenean blandit nunc vitae tempus sodales.\
                         In vehicula venenatis tempus. In pharetra aliquet neque, non viverra massa sodales eget.\
                         Etiam hendrerit tincidunt placerat. Suspendisse et lacus a metus tempor gravida.
                         New line!
                         """
        ),
        .init(
            title: "Description",
            description: "Not added yet..."
        ),
    ])
}

#endif
