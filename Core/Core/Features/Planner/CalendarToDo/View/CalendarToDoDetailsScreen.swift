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
import UIKit

public struct CalendarToDoDetailsScreen: View {
    @Environment(\.viewController) private var controller
    @ObservedObject private var viewModel: CalendarToDoDetailsViewModel

    public init(viewModel: CalendarToDoDetailsViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        InstUI.BaseScreen(state: viewModel.state, config: viewModel.screenConfig) { _ in
            eventContent
        }
        .navigationBarTitleView(viewModel.navigationTitle)
        .navBarItems(
            trailing: .moreIcon(
                isBackgroundContextColor: true,
                isEnabled: viewModel.isMoreButtonEnabled,
                isAvailableOffline: false,
                menuContent: {
                    InstUI.MenuItem.edit { viewModel.didTapEdit.send(controller) }
                    InstUI.MenuItem.delete { viewModel.didTapDelete.send(controller) }
                }
            )
        )
        .navigationBarStyle(.color(viewModel.navBarColor))
        .confirmationAlert(
            isPresented: $viewModel.shouldShowDeleteConfirmation,
            presenting: viewModel.deleteConfirmationAlert
        )
        .errorAlert(
            isPresented: $viewModel.shouldShowDeleteError,
            presenting: .init(
                title: String(localized: "Deletion not completed", bundle: .core),
                message: String(localized: "We couldn't delete your To Do at this time. You can try it again.", bundle: .core),
                buttonTitle: String(localized: "OK", bundle: .core)
            )
        )
    }

    @ViewBuilder
    private var eventContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let title = viewModel.title {
                Text(title)
                    .paragraphStyle(.heading)
            }
            if let date = viewModel.date {
                InstUI.TextSectionView(title: String(localized: "Date", bundle: .core),
                                       description: date)
            }
            if let description = viewModel.description {
                InstUI.TextSectionView(title: String(localized: "Description", bundle: .core),
                                       description: description)
            }
        }
    }
}

#if DEBUG

#Preview {
    let plannable = Plannable.save(
        APIPlannable.make(plannable: .init(
                details: """
                        The Assignment Details page displays the assignment title, points possible, submission\
                        status, and due date [1]. You can also view the assignment's submission types [2],\
                        as well as acceptable file types for file uploads if restricted by your instructor [3].
                        """,
                title: "Submit Creative Machines and Innovative Instrumentation - ASTR 21400"
            )
        ),
        userID: "",
        in: PreviewEnvironment().database.viewContext
    )
    return PlannerAssembly.makeToDoDetailsScreenPreview(plannable: plannable)
}

#endif
