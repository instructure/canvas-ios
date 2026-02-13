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

struct CourseCardView: View {
    @Environment(\.viewController) private var controller

    @State var viewModel: CourseCardViewModel

    var body: some View {
        Button(action: { viewModel.didTapCard(from: controller) }) {
            VStack(alignment: .leading, spacing: 8) {
                Text(viewModel.title)
                    .font(.semibold16, lineHeight: .fit)
                    .foregroundStyle(viewModel.color)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .paddingStyle(.standard)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .elevation(.cardLarge, background: .backgroundLightest)
        .accessibilityElement(children: .combine)
        .identifier("Dashboard.CourseCard.cardButton")
    }
}

#if DEBUG

extension CourseCardView {
    static let previewData: [CoursesAndGroupsWidgetCourseItem] = [
        .make(id: "1", title: "Introduction to Computer Science", color: "#008EE2"),
        .make(id: "2", title: "Advanced Mathematics", color: "#E91E63")
    ]
}

#Preview {
    PreviewContainer {
        VStack(spacing: 16) {
            CourseCardView(viewModel: CourseCardViewModel(
                model: CourseCardView.previewData[0],
                onCardTap: { _ in }
            ))

            CourseCardView(viewModel: CourseCardViewModel(
                model: CourseCardView.previewData[1],
                onCardTap: { _ in }
            ))
        }
        .padding(.horizontal, 16)
    }
}

#endif
