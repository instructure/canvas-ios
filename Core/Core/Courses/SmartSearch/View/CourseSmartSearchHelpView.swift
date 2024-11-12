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

public struct CourseSmartSearchHelpView: View {
    @Environment(\.sizeCategory) private var sizeCategory
    @Environment(\.courseSmartSearchContext) private var searchContext
    @Environment(\.viewController) private var controller

    public init() { }

    public var body: some View {
        let spacing = UIFontMetrics.default.scaledValue(for: 25)
        ScrollView {
            VStack(alignment: .leading, spacing: spacing)  {
                ParagraphView(title: Text("About Smart Search", bundle: .core)) {
                    Text("Smart Search, currently in development for Canvas, uses semantic algorithms and AI to understand query context and semantic meaning, not just keyword matching.", bundle: .core)
                }
                ParagraphView(title: Text("Using Smart Search", bundle: .core)) {
                    Text("Smart Search employs \"embeddings\" to mathematically represent content and queries for comparison, understanding keywords or general queries in any language, thanks to its multilingual AI model. Write search queries using keywords, questions, sentences, or whatever is most natural for you to describe what you are trying to find.", bundle: .core)
                }
                ParagraphView(title: Text("Searchable Content", bundle: .core)) {
                    Text("As of June 1, 2024, searchable items include content pages, announcements, discussion prompts, and assignment descriptions, with plans to expand.", bundle: .core)
                }
                ParagraphView(title: Text("Contributing to Development", bundle: .core)) {
                    Text("Smart Search is in feature preview. Feedback can be provided through result ratings and the Canvas Community space for Smart Search Beta. Canvas community space can be found here:", bundle: .core)
                    Link(destination: URL(string: "https://community.canvaslms.com/t5/Smart-Search/gh-p/smart_search")!) {
                        Text("Smart Search Community", bundle: .core)
                    }
                }
                ParagraphView(title: Text("Learn more", bundle: .core)) {
                    VStack(alignment: .leading) {
                        Link(destination: URL(
                            string: "https://community.canvaslms.com/t5/Smart-Search-Feature-Preview/Smart-Search-FAQ/ta-p/604415")!
                        ) {
                            Text("Smart Search FAQ", bundle: .core)
                        }
                        Link(destination: URL(
                            string: "https://community.canvaslms.com/t5/Artificial-Intelligence-in/AI-Nutrition-Facts-Canvas-Smart-Search/ta-p/608254"
                        )!) {
                            Text("AI Nutrition Facts", bundle: .core)
                        }
                    }
                }
            }
            .padding()
            .padding(.bottom, spacing)
        }
        .navigationTitle(Text("How it works", bundle: .core))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    controller.value.dismiss(animated: true)
                } label: {
                    Text("Close", bundle: .core)
                }
            }
        }
        .tint(contextColor)
    }

    private var contextColor: Color {
        return Color(uiColor: searchContext.info.color ?? .textDarkest)
    }
}

private struct ParagraphView<Content: View>: View {
    @Environment(\.sizeCategory) private var sizeCategory

    let title: Text
    @ViewBuilder let content: () -> Content

    var body: some View {
        let spacing = UIFontMetrics.default.scaledValue(for: 10)
        VStack(alignment: .leading, spacing: spacing) {
            title.textStyle(.heading)
            content()
        }
    }
}
