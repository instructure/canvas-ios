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

public extension AUI {

    struct TextSectionView: View {
        public struct Model: Identifiable, Equatable {
            public var id: String { title + description }

            public let title: String
            public let description: String
            public let isRichContent: Bool
            public let baseUrl: URL?

            public init(
                title: String,
                description: String,
                isRichContent: Bool = false,
                baseUrl: URL? = nil
            ) {
                self.title = title
                self.description = description
                self.isRichContent = isRichContent
                self.baseUrl = baseUrl
            }
        }

        @Environment(\.dynamicTypeSize) private var dynamicTypeSize

        private let sectionData: [Model]

        public init(
            title: String,
            description: String,
            isRichContent: Bool = false,
            baseUrl: URL? = nil
        ) {
            sectionData = [
                .init(title: title, description: description, isRichContent: isRichContent, baseUrl: baseUrl)
            ]
        }

        public init(_ sectionData: [Model]) {
            self.sectionData = sectionData
        }

        public init(_ sectionData: Model?) {
            self.sectionData = (sectionData == nil ? [] : [sectionData!])
        }

        @ViewBuilder
        public var body: some View {
            if sectionData.isEmpty {
                SwiftUI.EmptyView()
            } else {
                VStack(spacing: 0) {
                    AUI.Divider()

                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(sectionData) { sectionData in
                            VStack(
                                alignment: .leading,
                                spacing: AUI.Styles.Padding.textVertical.rawValue
                            ) {
                                Text(sectionData.title)
                                    .textStyle(.infoTitle)
                                    .accessibilityAddTraits(.isHeader)

                                if sectionData.isRichContent {
                                    WebView(
                                        html: sectionData.description,
                                        baseURL: sectionData.baseUrl,
                                        features: [],
                                        canToggleTheme: true
                                    )
                                    .frameToFit()
                                    .padding(
                                        .horizontal,
                                        -AUI.Styles.Padding.standard.rawValue
                                    )
                                } else {
                                    Text(sectionData.description)
                                        .textStyle(.infoDescription)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .paddingStyle(.top, .paragraphTop)
                            // .combine doesn't work for WebView
                            .accessibilityElement(children: sectionData.isRichContent ? .contain : .combine)
                        }
                    }
                    .paddingStyle(.horizontal, .standard)
                    .paddingStyle(.bottom, .paragraphBottom)
                }
            }
        }
    }
}

#if DEBUG

#Preview("Empty Array") {
    AUI.TextSectionView([])
}

#Preview("Nil Entity") {
    AUI.TextSectionView([])
}

#Preview("Short Text") {
    AUI.TextSectionView(title: "Description",
                           description: "Not added yet...")
}

#Preview("Rich Content") {
    AUI.TextSectionView([
        .init(
            title: "Rich Content",
            description: "<a href=\"\">Click here!</a>",
            isRichContent: true
        ),
        .init(
            title: "Non Rich Content Reference",
            description: "Click here!",
            isRichContent: false
        )
    ])
}

#Preview("Long Text") {
    AUI.TextSectionView(title: AUI.PreviewData.loremIpsumMedium,
                           description: AUI.PreviewData.loremIpsumLong)
}

#Preview("Multiple Sections") {
    AUI.TextSectionView([
        .init(
            title: AUI.PreviewData.loremIpsumMedium,
            description: AUI.PreviewData.loremIpsumLong
        ),
        .init(
            title: "Description",
            description: "Not added yet..."
        )
    ])
}

#endif
