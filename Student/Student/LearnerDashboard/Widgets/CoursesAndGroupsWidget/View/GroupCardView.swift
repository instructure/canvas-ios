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

struct GroupCardView: View {
    @Environment(\.viewController) private var controller

    @State var viewModel: GroupCardViewModel

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
        .identifier("Dashboard.GroupCard.cardButton")
    }
}

#if DEBUG

extension GroupCardView {
    static let previewData: [CoursesAndGroupsWidgetGroupItem] = [
        .make(id: "1", title: "Study Group A", colorString: "#4CAF50"),
        .make(id: "2", title: "Project Team", colorString: "#FF9800")
    ]
}

#Preview {
    PreviewContainer {
        VStack(spacing: 16) {
            GroupCardView(viewModel: GroupCardViewModel(
                model: GroupCardView.previewData[0],
                onCardTap: { _ in }
            ))

            GroupCardView(viewModel: GroupCardViewModel(
                model: GroupCardView.previewData[1],
                onCardTap: { _ in }
            ))
        }
        .padding(.horizontal, 16)
    }
}

#endif
