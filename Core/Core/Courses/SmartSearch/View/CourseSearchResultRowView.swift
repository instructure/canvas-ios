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

struct CourseSearchResultRowView: View {
    @Environment(\.appEnvironment) private var env
    @Environment(\.viewController) private var controller
    @Environment(\.courseSmartSearchContext) private var searchContext

    @State private var isVisited: Bool = false

    @Binding var selected: ID?

    let result: CourseSmartSearchResult
    var showsType: Bool = true

    var body: some View {
        Button {
            env.router.route(to: routePath, from: controller, options: .detail)
            searchContext.markVisited(result.content_id)
            selected = result.content_id
        } label: {
            HStack(alignment: .top, spacing: 16) {
                result.content_type.icon.foregroundStyle(color)
                VStack(alignment: .leading, spacing: 5) {
                    KeywordHighlightingText(
                        text: result.title,
                        keyword: searchContext.searchText.value,
                        customization: .init(
                            font: .scaledNamedFont(.semibold16),
                            lineLimit: nil,
                            backgroundColor: .init(hexString: "#C6DFEF") ?? .backgroundDark
                        )
                    )
                    .foregroundStyle(color)

                    if showsType {
                        Text(result.readable_type).font(.regular14).foregroundStyle(color)
                    }
                    if result.body.isNotEmpty {
                        KeywordHighlightingText(
                            text: result.body,
                            keyword: searchContext.searchText.value,
                            customization: .init(
                                backgroundColor: .init(hexString: "#C6DFEF") ?? .backgroundDark
                            )
                        )
                        .foregroundStyle(Color.textDark)
                        .multilineTextAlignment(.leading)
                    }
                }
                Spacer()
                VStack {
                    Spacer()
                    HStack(spacing: 2) {
                        ForEach(1 ..< 5) { i in
                            Rectangle()
                                .fill(
                                    i <= result.distanceDots
                                    ? result.strengthColor
                                    : Color.borderMedium
                                )
                                .frame(width: 4, height: 4)
                        }
                    }
                    Spacer()
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.contextButton(color: searchContext.info.color, state: buttonState))
        .onReceive(searchContext.visitedRecordPublisher) { history in
            isVisited = history.contains(result.content_id)
        }
    }

    private var buttonState: ContextButtonState {
        if selected == result.id { return .selected }
        if isVisited { return .highlighted }
        return .normal
    }

    private var routePath: String {
        return "/" + [
            searchContext.info.context.pathComponent,
            result.pathComponent
        ].joined(separator: "/")
    }

    private var color: Color {
        Color(uiColor: searchContext.info.color ?? .gray)
    }
}
