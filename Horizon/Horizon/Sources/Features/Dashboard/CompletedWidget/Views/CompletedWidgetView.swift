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

import HorizonUI
import SwiftUI

struct CompletedWidgetView: View {
    private let viewModel: CompletedWidgetViewModel

    init(viewModel: CompletedWidgetViewModel) {
        self.viewModel = viewModel
    }
    var body: some View {
        VStack(spacing: .huiSpaces.space8) {
            CompletedWidgetHeader()
                .accessibilityHidden(viewModel.state == .loading)
            switch viewModel.state {
            case .data, .loading:
                dataView
            case .empty:
                emptyView
            case .error:
                errorView
            }
        }
        .padding(.huiSpaces.space24)
        .background(Color.huiColors.surface.pageSecondary)
        .huiCornerRadius(level: .level5)
        .huiElevation(level: .level4)
        .isSkeletonLoadActive(viewModel.state == .loading)
        .fixedSize(horizontal: true, vertical: false)
        .accessibilityElement(children: viewModel.state == .loading ? .ignore : .contain)
        .accessibilityLabel(
            viewModel.state == .loading
                            ? Text(String(localized: "Loading courses progress", bundle: .horizon))
                            : nil
        )
        .onWidgetReload { _ in
            viewModel.getCompletedModulesCount(ignoreCache: true)
        }
    }

    private var dataView: some View {
        HStack(spacing: .huiSpaces.space8) {
            Text(viewModel.totalCount.description)
                .huiTypography(.labelSemibold)
                .foregroundStyle(Color.huiColors.text.body)
                .skeletonLoadable()
                .accessibilityHidden(viewModel.state == .loading)
            Text("completed", bundle: .horizon)
                .huiTypography(.labelMediumBold)
                .foregroundStyle(Color.huiColors.text.body)
                .skeletonLoadable()
                .accessibilityHidden(viewModel.state == .loading)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            Text(
                String.localizedStringWithFormat(
                        String(localized: "%@ completed modules", bundle: .horizon),
                        viewModel.totalCount.description,
                    )
            )
        )
    }

    private var emptyView: some View {
        WidgetEmptyView()
    }

    private var errorView: some View {
        WidgetErrorView {
            viewModel.getCompletedModulesCount(ignoreCache: true)
        }
    }
}

#if DEBUG
#Preview {
    VStack {
        CompletedWidgetAssembly.makePreview(hasError: true)
        CompletedWidgetAssembly.makePreview(hasError: false)
    }
}
#endif
