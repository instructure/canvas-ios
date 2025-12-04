//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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
import HorizonUI

struct CourseProgressView: View {
    @Environment(\.viewController) private var viewController
    @AccessibilityFocusState private var focusedItemID: String?
    private let viewModel: CourseProgressViewModel

    init(viewModel: CourseProgressViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ScrollView {
            VStack(spacing: .huiSpaces.space16) {
                headerView
                ModuleItemListView(
                    selectedModuleItem: viewModel.currentModuleItem,
                    items: viewModel.moduleItems,
                    focusedID: $focusedItemID,
                    onSelectItem: onSelectItem
                )
                .animation(.smooth, value: viewModel.currentModuleItem)
            }
        }
        .safeAreaInset(edge: .bottom, content: {
            moduleNavBarButtons
        })
        .padding(.horizontal, .huiSpaces.space24)
        .animation(.smooth, value: viewModel.currentModuleItem)
        .overlay(alignment: .topTrailing) {
            HorizonUI.IconButton(Image.huiIcons.close, type: .white, isSmall: true) {
                viewModel.dimiss(controller: viewController)
            }
            .huiElevation(level: .level4)
            .padding(.huiSpaces.space24)
            .accessibilityAddTraits(.isButton)
            .accessibilityLabel(Text("Dismiss screen. "))
        }
        .background(Color.huiColors.surface.pagePrimary)
        .onAppear {
            focusedItemID = viewModel.currentModuleItem?.id
        }
    }

    private var headerView: some View {
        VStack(spacing: .huiSpaces.space32) {
            Text("My Progress", bundle: .horizon)
                .foregroundStyle(Color.huiColors.text.title)
                .frame(maxWidth: .infinity)
                .huiTypography(.h3)
                .accessibilityAddTraits(.isHeader)

            Text(viewModel.moduleName)
                .foregroundStyle(Color.huiColors.text.body)
                .frame(maxWidth: .infinity, alignment: .leading)
                .huiTypography(.labelLargeBold)
        }
        .padding(.top, .huiSpaces.space32)
    }

    @ViewBuilder
    private var moduleNavBarButtons: some View {
        let nextButton = ModuleNavBarView.ButtonAttribute(
            isVisible: viewModel.isNextButtonEnabled,
            accessibilityLabel: String(localized: "Go to next module", bundle: .horizon)

        ) {
            withAnimation {
                viewModel.goToNextModule()
            }
        }

        let previousButton = ModuleNavBarView.ButtonAttribute(
            isVisible: viewModel.isPreviousButtonEnabled,
            accessibilityLabel: String(localized: "Back to previous module", bundle: .horizon)
        ) {
            withAnimation {
                viewModel.goToPreviousModule()
            }
        }

        ModuleItemSequenceAssembly.makeModuleNavBarView(
            nextButton: nextButton,
            previousButton: previousButton,
            visibleButtons: []
        )
    }

    private func onSelectItem(_ moduleItem: HModuleItem) {
        viewModel.currentModuleItem = moduleItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            viewModel.dimiss(controller: viewController)
        }
    }
}

#Preview {
    CourseProgressAssembly.makeViewPreview()
}
