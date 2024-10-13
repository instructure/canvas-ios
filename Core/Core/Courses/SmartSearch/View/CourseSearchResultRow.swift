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

struct CourseSearchResultRow: View {
    @Environment(\.appEnvironment) var env
    @Environment(\.viewController) var controller
    @Environment(\.searchContext) var searchContext

    var color: Color {
        Color(uiColor: searchContext.color ?? .gray)
    }

    let result: SearchResult
    var showType: Bool = true
    var last: Bool = false

    var body: some View {
        Button {
            let content = CoreHostingController(
                VStack(alignment: .leading) {
                    Text(result.title)
                    Text(result.readable_type)
                    Text(result.body)
                }
                    .padding()
            )
            env.router.show(content, from: controller, options: .detail)
        } label: {
            HStack(alignment: .top, spacing: 16) {
                result.content_type.icon.tint(color)
                VStack(alignment: .leading, spacing: 5) {
                    Text(result.title).font(.semibold16).foregroundStyle(color)
                    if showType {
                        Text(result.readable_type).font(.regular14).foregroundStyle(color)
                    }
                    Text(result.body)
                        .font(.regular14)
                        .foregroundStyle(Color.textDark)
                        .multilineTextAlignment(.leading)
                        .lineLimit(3)
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
            .overlay(alignment: .bottom) {
                SearchDivider(inset: last == false)
            }
        }
    }
}
