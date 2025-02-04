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
    private let viewModel: CourseProgressViewModel

    init(viewModel: CourseProgressViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(spacing: .zero) {
            ScrollView {
                VStack(spacing: .huiSpaces.primitives.mediumSmall) {
                    headerView
                    ModuleItemListView(selectedModuleItem: viewModel.currentModuleItem, items: viewModel.moduleItems) { selectedItem in
                        viewModel.currentModuleItem = selectedItem
                    }
                    .animation(.smooth, value: viewModel.currentModuleItem)
                }
            }
            Spacer()
            moduleNavBarButtons
        }
        .padding(.horizontal, .huiSpaces.primitives.medium)
        .animation(.smooth, value: viewModel.currentModuleItem)
        .overlay(alignment: .topTrailing) {
            HorizonUI.IconButton(Image.huiIcons.close, type: .white) {
                viewModel.dimiss(controller: viewController)
            }
            .huiElevation(level: .level4)
            .padding(.huiSpaces.primitives.medium)
        }
        .background(Color.huiColors.surface.pagePrimary)
    }

    private var headerView: some View {
        VStack(spacing: .huiSpaces.primitives.medium) {
            Text("My Progress", bundle: .horizon)
                .foregroundStyle(Color.huiColors.text.title)
                .frame(maxWidth: .infinity)
                .huiTypography(.h3)

            Text(viewModel.moduleName)
                .foregroundStyle(Color.huiColors.text.body)
                .frame(maxWidth: .infinity, alignment: .leading)
                .huiTypography(.labelLargeBold)
        }
        .padding(.top, .huiSpaces.primitives.medium)
    }

    private var moduleNavBarButtons: some View {
        ModuleItemSequenceAssembly.makeModuleNavBarView(
            isNextButtonEnabled: viewModel.isNextButtonEnabled,
            isPreviousButtonEnabled: viewModel.isPreviousButtonEnabled,
            isShowUtilityButtons: false
        ) {
            withAnimation {
                viewModel.goToNextModule()
            }
        } didTapPrevious: {
            withAnimation {
                viewModel.goToPreviousModule()
            }
        }
    }
}

#Preview {
    CourseProgressAssembly.makeViewPreview()
}
