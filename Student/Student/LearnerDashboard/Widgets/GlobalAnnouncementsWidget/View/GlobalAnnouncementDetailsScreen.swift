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

struct GlobalAnnouncementDetailsScreen: View {
    @Environment(\.viewController) private var controller

    @State var viewModel: GlobalAnnouncementDetailsViewModel

    init(viewModel: GlobalAnnouncementDetailsViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        InstUI.BaseScreen(state: .data, config: .notRefreshable) { _ in
            contentView
        }
        .navigationTitle(String(localized: "Global Announcement", bundle: .student), style: .modal)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    viewModel.didTapClose(from: controller)
                } label: {
                    Text("Close", bundle: .core)
                        .font(.regular16)
                        .foregroundStyle(.brandPrimary)
                }
                .identifier("GlobalAnnouncement.closeButton")
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.didTapDismiss(from: controller)
                } label: {
                    Text("Dismiss", bundle: .core)
                        .font(.semibold16)
                        .foregroundStyle(.brandPrimary)
                }
                .identifier("GlobalAnnouncement.dismissButton")
            }
        }
    }

    @ViewBuilder
    private var contentView: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(viewModel.title)
                .paragraphStyle(.heading)
                .accessibilityAddTraits(.isHeader)

            if let date = viewModel.date {
                InstUI.TextSectionView(
                    title: String(localized: "Date", bundle: .student),
                    description: date
                )
            }

            InstUI.TextSectionView(
                title: String(localized: "Message", bundle: .student),
                description: viewModel.message,
                isRichContent: true,
                baseUrl: viewModel.baseUrl
            )
        }
    }
}

#if DEBUG

#Preview {
    let item = GlobalAnnouncementsWidgetItem.make(
        id: "1",
        title: "Important Campus Update",
        icon: .information,
        startDate: Date(),
        message: "This is an important announcement about upcoming campus events. Please review this information carefully."
    )

    let viewModel = GlobalAnnouncementDetailsViewModel(
        item: item,
        interactor: GlobalAnnouncementsWidgetInteractorMock(),
        environment: PreviewEnvironment()
    )

    return GlobalAnnouncementDetailsScreen(viewModel: viewModel)
}

#endif
