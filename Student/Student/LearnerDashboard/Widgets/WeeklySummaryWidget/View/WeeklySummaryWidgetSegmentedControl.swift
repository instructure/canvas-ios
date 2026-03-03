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

struct WeeklySummaryWidgetSegmentedControl: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.redactionReasons) private var redactionReasons
    var viewModel: WeeklySummaryWidgetViewModel

    @Namespace private var selectionNamespace

    var body: some View {
        ZStack {
            selectionIndicator
            buttonsRow
        }
        .padding(2)
        .frame(minHeight: 64)
        .elevation(cornerRadius: 8, background: Color.backgroundLight)
        .animation(WeeklySummaryWidgetView.animation, value: viewModel.expandedFilter)
    }

    private var buttonsRow: some View {
        HStack(spacing: 0) {
            categoryButton(viewModel.missingFilter)
            divider(between: viewModel.missingFilter, and: viewModel.dueFilter)
            categoryButton(viewModel.dueFilter)
            divider(between: viewModel.dueFilter, and: viewModel.newGradesFilter)
            categoryButton(viewModel.newGradesFilter)
        }
    }

    private func categoryButton(_ filter: WeeklySummaryWidgetFilterViewModel) -> some View {
        let isExpanded = viewModel.expandedFilter == filter
        return Button {
            viewModel.toggleFilter(filter)
        } label: {
            VStack(spacing: 0) {
                ZStack {
                    // Adding extra spaces so the redaction looks wider and better
                    Text("\(redactionReasons.isPlaceholder ? "  " : "")\(filter.count)")
                        .font(.bold22)
                        .foregroundStyle(Color.textDarkest)
                        .frame(maxWidth: .infinity)
                    HStack {
                        Spacer()
                        Image.chevronDown
                            .scaledIcon(size: 16)
                            .foregroundStyle(Color.textDarkest)
                            .rotationEffect(isExpanded ? .degrees(180) : .zero)
                    }
                    .unredacted()
                }
                Text(filter.label)
                    .font(.regular12)
                    .foregroundStyle(Color.textDark)
                    .unredacted()
            }
            .padding(.vertical, 3)
            .padding(.horizontal, 8)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .matchedGeometryEffect(id: filter.id, in: selectionNamespace, isSource: true)
        }
        .accessibilityLabel(filter.accessibilityLabel)
        .accessibilityValue(filter.accessibilityValue)
        .accessibilityHint(filter.accessibilityHint)
        .accessibilityAddTraits(.isHeader)
    }

    @ViewBuilder
    private var selectionIndicator: some View {
        if let selected = viewModel.expandedFilter {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.backgroundLightest)
                .shadow(color: .black.opacity(0.12), radius: 4, x: 0, y: 2)
                .matchedGeometryEffect(id: selected.id, in: selectionNamespace, isSource: false)
                .transition(.scale.combined(with: .opacity))
                .allowsHitTesting(false)
        }
    }

    private func divider(
        between leading: WeeklySummaryWidgetFilterViewModel,
        and trailing: WeeklySummaryWidgetFilterViewModel
    ) -> some View {
        let isHidden = viewModel.expandedFilter == leading || viewModel.expandedFilter == trailing
        return InstUI.Divider()
            .padding(.vertical, 8)
            .opacity(isHidden ? 0 : 1)
    }
}

#if DEBUG

#Preview {
    @Previewable @State var viewModel = WeeklySummaryWidgetViewModel(
        config: .make(id: .weeklySummary),
        router: PreviewEnvironment().router
    )
    VStack {
        WeeklySummaryWidgetSegmentedControl(viewModel: viewModel)
        WeeklySummaryWidgetSegmentedControl(viewModel: viewModel)
            .redacted(reason: .placeholder)
    }
    .padding(16)
    .background(Color.course4)
}

#endif
