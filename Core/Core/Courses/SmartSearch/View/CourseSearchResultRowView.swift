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
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @State private var isVisited: Bool = false
    @Binding var selectedId: ID?

    let result: CourseSmartSearchResult
    var showsType: Bool = true

    var body: some View {
        Button {
            env.router.route(to: routePath, from: controller, options: .detail)
            searchContext.markVisited(result.content_id)
            selectedId = result.content_id
        } label: {
            HStack(alignment: .top, spacing: 0) {
                result.content_type.icon.foregroundStyle(accentColor)
                Spacer().frame(width: InstUI.Styles.Padding.cellIconText.rawValue)
                VStack(alignment: .leading, spacing: 5) {
                    Text(result.title).font(.semibold16).foregroundStyle(titleColor)
                    if showsType {
                        Text(result.readable_type).font(.regular14).foregroundStyle(accentColor)
                    }
                    if result.body.isNotEmpty {
                        Text(result.body)
                            .font(.regular14)
                            .foregroundStyle(Color.textDark)
                            .multilineTextAlignment(.leading)
                            .lineLimit(3)
                    }
                }
                Spacer(minLength: InstUI.Styles.Padding.cellAccessoryPadding.rawValue)
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
            .paddingStyle(set: .iconCell)
            .contentShape(Rectangle())
        }
        .buttonStyle(.contextButton(color: searchContext.accentColor, isHighlighted: isHighlighted))
        .onReceive(searchContext.visitedRecordPublisher) { history in
            isVisited = history.contains(result.content_id)
        }
    }

    private var isHighlighted: Bool { selectedId == result.id }

    private var routePath: String {
        return "/" + [
            searchContext.attributes.context.pathComponent,
            result.pathComponent
        ].joined(separator: "/")
    }

    private var accentColor: Color {
        Color(uiColor: searchContext.accentColor ?? .textDarkest)
    }

    private var titleColor: Color {
        let visitedColor = searchContext.accentColor ?? .textDarkest
        return Color(uiColor: isVisited ? visitedColor : .textDarkest)
    }
}
