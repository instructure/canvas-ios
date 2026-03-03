//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

struct WeeklySummaryEmptyView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let filter: WeeklySummaryFilterViewModel

    var body: some View {
        DashboardWidgetCard {
            HStack(spacing: 8) {
                Image(filter.emptyStateIconName, bundle: .core)
                    .resizable()
                    .scaledToFit()
                    .scaledFrame(width: 72, height: 40)
                    .accessibilityHidden(true)
                Text(filter.emptyStateText)
                    .font(.regular14)
                    .foregroundStyle(Color.textDark)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
        }
    }
}

#if DEBUG

#Preview {
    VStack(spacing: 12) {
        WeeklySummaryEmptyView(filter: .missing(assignments: []))
        WeeklySummaryEmptyView(filter: .due(assignments: []))
        WeeklySummaryEmptyView(filter: .newGrades(assignments: []))
    }
    .padding(16)
    .background(Color.course4)
}

#endif
