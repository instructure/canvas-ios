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

struct CourseSearchResultsHeaderView: View {

    let course: Course?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Results in course")
                .lineLimit(1)
                .font(.regular16)
                .foregroundStyle(Color.textDark)
            Text(course?.name ?? "")
                .font(.semibold16)
                .foregroundStyle(Color.textDarkest)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 14)
        .background(Color.backgroundLightest)
        .cornerRadius(6)
        .shadow(color: Color(white: 0, opacity: 0.08), radius: 6, y: 2)
        .shadow(color: Color(white: 0, opacity: 0.16), radius: 2, y: 1)
        .padding(16)
        .background(Color.backgroundLight)
        .overlay(alignment: .bottom) {
            InstUI.Divider()
        }
    }
}
