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

import Core
import SwiftUI

struct LearningObjectHeaderView: View {
    let type: String
    let duration: String
    let courseName: String
    let courseProgress: Double
    let courseDueDate: String
    let courseState: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 4) {
                Image(systemName: "document")
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(Color.textDarkest)
                    .frame(width: 14, height: 14)
                Size12RegularTextDarkestTitle(title: type)
                Spacer()
                Image(systemName: "timer")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(Color.textDarkest)
                    .frame(width: 14, height: 14)
                Size12RegularTextDarkestTitle(title: duration)
            }
            Size12RegularTextDarkTitle(title: courseName)
                .padding(.top, 2)
            ContentProgressBar(
                progress: 0.30
            )
            .padding(.top, 12)

            HStack(spacing: 0) {
                Size12RegularTextDarkestTitle(title: courseState)
                Spacer()
                Size12RegularTextDarkestTitle(title: courseDueDate)
            }
            .padding(.top, 2)
        }
    }
}

#Preview {
    LearningObjectHeaderView(
        type: "Assignment",
        duration: "20 mins",
        courseName: "Design Thinking Workshop",
        courseProgress: 0.75,
        courseDueDate: "01/12/2024",
        courseState: "Not Started"
    )
}
