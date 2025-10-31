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

struct SkillsCountWidgetView: View {
    @Environment(\.dashboardLastFocusedElement) private var lastFocusedElement
    @Environment(\.dashboardRestoreFocusTrigger) private var restoreFocusTrigger
    @AccessibilityFocusState private var isFocused: Bool

    // MARK: - Dependencies

    private let viewModel: SkillsHighlightsWidgetViewModel
    private let onTap: () -> Void

    // MARK: - Init

    init(
        viewModel: SkillsHighlightsWidgetViewModel,
        onTap: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.onTap = onTap
    }

    var body: some View {
        Button {
            onTap()
            lastFocusedElement.wrappedValue = .skillsCountWidget
        } label: {
            VStack(alignment: .leading, spacing: .huiSpaces.space8) {
                SkillsCountWidgetHeaderView()
                switch viewModel.state {
                case .loading:
                    dataView(count: 1, isLoading: true)
                case .data:
                    dataView(count: viewModel.countSkills)
                case .empty:
                    emptyView
                case .error:
                    errorView
                }
            }
        }
        .padding(.huiSpaces.space24)
        .background(Color.huiColors.surface.pageSecondary)
        .huiCornerRadius(level: .level5)
        .huiElevation(level: .level4)
        .isSkeletonLoadActive(viewModel.state == .loading)
        .containerRelativeFrame(.horizontal)
        .buttonStyle(.plain)
        .accessibilityFocused($isFocused)
        .accessibilityHint(String(localized: "Double tap to open skillspace", bundle: .horizon))
        .onChange(of: restoreFocusTrigger) { _, _ in
            if let lastFocused = lastFocusedElement.wrappedValue,
               case .skillsCountWidget = lastFocused {
                DispatchQueue.main.async {
                    isFocused = true
                }
            }
        }
    }

    @ViewBuilder
    private func dataView(count: Int, isLoading: Bool = false) -> some View {
        HStack(spacing: .huiSpaces.space8) {
            Text(count.description)
                .huiTypography(.labelSemibold)
                .foregroundStyle(Color.huiColors.text.body)
                .skeletonLoadable()
                .accessibilityHidden(isLoading)
            Text("earned", bundle: .horizon)
                .huiTypography(.labelMediumBold)
                .foregroundStyle(Color.huiColors.text.body)
                .skeletonLoadable()
                .accessibilityHidden(isLoading)
        }
        .accessibilityElement(children: isLoading ? .ignore : .combine)
        .accessibilityLabel(
            Text(
                isLoading
                    ? String(localized: "Loading skills earned", bundle: .horizon)
                    : String.localizedStringWithFormat(String(localized: "%@ Skills earned", bundle: .horizon), count.description)
            )
        )
    }

    private var emptyView: some View {
        WidgetEmptyView()
    }

    private var errorView: some View {
        WidgetErrorView {
            viewModel.getSkills(ignoreCache: true)
        }
    }
}

#if DEBUG
    #Preview {
        VStack {
            SkillsCountWidgetView(
                viewModel: .init(
                    interactor: SkillsWidgetInteractorPreview(shouldReturnError: true)
                )
            ) {  }
            SkillsCountWidgetView(
                viewModel: .init(
                    interactor: SkillsWidgetInteractorPreview(shouldReturnError: false)
                )
            ) {  }
        }
        .padding(.horizontal, 24)
    }
#endif
