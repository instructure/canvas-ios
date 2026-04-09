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
import HorizonUI
import SwiftUI

struct ManageOfflineContentView: View {
    // MARK: - Properties

    @Environment(\.viewController) private var viewController
    @State private var viewModel: ManageOfflineContentViewModel

    // MARK: - Init

    init(viewModel: ManageOfflineContentViewModel) {
        self._viewModel = State(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            Color.huiColors.surface.pagePrimary.edgesIgnoringSafeArea(.all)
            scrollContent
        }
        .toolbar(.hidden)
        .safeAreaInset(edge: .bottom, spacing: .zero) { bottomActionBar }
    }

    // MARK: - Navigation Bar

    private var navigationBar: some View {
        TitleBar(
            onBack: { _ in  viewModel.pop(viewController: viewController) },
            onClose: nil
        ) {
            Text("Manage offline content", bundle: .horizon)
                .frame(maxWidth: .infinity)
                .huiTypography(.h3)
                .accessibilityAddTraits(.isHeader)
                .foregroundStyle(Color.huiColors.text.title)
        }
        .padding(.bottom, .huiSpaces.space16)
        .padding(.horizontal, .huiSpaces.space24)
        .padding(.top, .huiSpaces.space8)
        .background(Color.huiColors.surface.pagePrimary)
        .accessibilityElement(children: .contain)
    }

    // MARK: - Scroll Content

    private var scrollContent: some View {
        ScrollView {
            VStack(spacing: .huiSpaces.space8) {
                OfflineStorageView(
                    viewModel: CourseSyncDiskSpaceInfoViewModel(
                        interactor: DiskSpaceInteractorLive(),
                        app: .horizon
                    )
                )
                contentListSection
            }
            .padding(.top, .huiSpaces.space32)
        }
        .background(Color.huiColors.surface.pageSecondary)
        .huiCornerRadius(level: .level5, corners: [.topLeft, .topRight])
        .safeAreaInset(edge: .top, spacing: .zero) { navigationBar }
    }

    private var contentListSection: some View {
        VStack(spacing: .zero) {
            selectAllButton
            OfflineCourseListView(
                courses: viewModel.courses,
                onToggleCourse: { viewModel.toggleCourse($0) },
                onToggleExpand: { viewModel.toggleExpand($0) },
                onToggleSubItem: { viewModel.toggleSubItem(courseID: $0, subItemID: $1) }
            )
        }
        .background(Color.huiColors.surface.pageSecondary)
    }

    private var selectAllButton: some View {
        Button {
            viewModel.toggleSelectAll()
        } label: {
            Text("Select all", bundle: .horizon)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(Color.huiColors.text.title)
                .huiTypography(.buttonTextLarge)
        }
        .padding(.horizontal, .huiSpaces.space16)
        .accessibilityValue(viewModel.selectAllState.accessibilityValue)
    }

    private var bottomActionBar: some View {
        VStack(spacing: .huiSpaces.space12) {
            HorizonUI.PrimaryButton(
                String(localized: "Sync"),
                type: .black,
                fillsWidth: true,
                trailing: Image.huiIcons.sync
            ) {

            }
            .disabled(viewModel.selectAllState == .unchecked)

            HorizonUI.PrimaryButton(
                String(localized: "Remove synced content"),
                type: .dangerOutline,
                fillsWidth: true,
                trailing: Image.huiIcons.cancel
            ) {

            }
        }
        .padding([.horizontal, .top], .huiSpaces.space16)
        .background(Color.huiColors.surface.pageSecondary)
        .shadow(
            color: HorizonUI.colors.surface.inversePrimary.opacity(0.1),
            radius: 8,
            x: 1,
            y: 2
        )
    }
}

#if DEBUG
#Preview {
    let viewModel = ManageOfflineContentViewModel(router: AppEnvironment.shared.router)
    ManageOfflineContentView(viewModel: viewModel)
}
#endif
