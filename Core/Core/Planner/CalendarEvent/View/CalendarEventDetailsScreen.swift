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

public struct CalendarEventDetailsScreen: View, ScreenViewTrackable {
    public var screenViewTrackingParameters: ScreenViewTrackingParameters { viewModel.pageViewEvent }

    @Environment(\.viewController) private var controller
    @ObservedObject private var viewModel: CalendarEventDetailsViewModel

    public init(viewModel: CalendarEventDetailsViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        InstUI.BaseScreen(
            state: viewModel.state,
            refreshAction: viewModel.reload
        ) { _ in
            eventContent
        }
        .navigationTitle(viewModel.pageTitle, subtitle: viewModel.pageSubtitle)
        .navBarItems(
            trailing: ExperimentalFeature.modifyCalendarEvent.isEnabled && viewModel.shouldShowMenuButton
            ? .moreIcon(
                isBackgroundContextColor: true,
                isEnabled: viewModel.isMoreButtonEnabled,
                isAvailableOffline: false,
                menuContent: {
                    InstUI.MenuItem.edit { viewModel.didTapEdit.send(controller) }
                    InstUI.MenuItem.delete { viewModel.didTapDelete.send(controller) }
                }
            )
            : nil
        )
        .navigationBarStyle(.color(viewModel.contextColor))
        .confirmationAlert(
            isPresented: $viewModel.shouldShowDeleteConfirmation,
            presenting: viewModel.deleteConfirmationAlert
        )
        .errorAlert(
            isPresented: $viewModel.shouldShowDeleteError,
            presenting: .init(
                title: String(localized: "Deletion not completed", bundle: .core),
                message: String(localized: "We couldn't delete your Event at this time. You can try it again.", bundle: .core),
                buttonTitle: String(localized: "OK", bundle: .core)
            )
        )
    }

    private var eventContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            InstUI.Header(title: viewModel.title, subtitle: viewModel.date)
            InstUI.TextSectionView(viewModel.locationInfo)
            InstUI.TextSectionView(viewModel.details)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#if DEBUG

#Preview {
    PlannerAssembly.makeEventDetailsScreenPreview()
}

#endif
