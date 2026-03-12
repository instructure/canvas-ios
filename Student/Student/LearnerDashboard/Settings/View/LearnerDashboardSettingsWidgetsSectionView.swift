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

import SwiftUI
import Core
import HorizonUI

struct LearnerDashboardSettingsWidgetsSectionView: View {
    @State var viewModel: LearnerDashboardSettingsWidgetsSectionViewModel
    @Environment(\.dynamicTypeSize) var dynamicTypeSize

    var body: some View {
        VStack(spacing: 8) {
            Text("Widgets", bundle: .student)
                .foregroundStyle(.textDarkest)
                .font(.regular14, lineHeight: .fit)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)

            VStack(spacing: 16) {
                ForEach(viewModel.configs) { config in
                    LearnerDashboardSettingsWidgetCardView(
                        config: config,
                        username: viewModel.username,
                        isVisible: Binding {
                            config.isVisible
                        } set: {
                            viewModel.toggleVisibility(of: config, to: $0)
                        },
                        isMoveUpDisabled: viewModel.isMoveUpDisabled(of: config),
                        isMoveDownDisabled: viewModel.isMoveDownDisabled(of: config),
                        onMoveUp: { viewModel.moveUp(config) },
                        onMoveDown: { viewModel.moveDown(config) },
                        subSettingsView: viewModel.subSettingsViews[config.id]
                    )
                }
            }
        }
    }

    init(viewModel: LearnerDashboardSettingsWidgetsSectionViewModel) {
        _viewModel = State(initialValue: viewModel)
    }
}

#Preview {
    VStack {
        LearnerDashboardSettingsWidgetsSectionView(viewModel: {
            let defaults = SessionDefaults.fallback
            let configs: [DashboardWidgetConfig] = [
                .init(id: .helloWidget, order: 0, isVisible: true),
                .init(id: .coursesAndGroups, order: 1, isVisible: false)
            ]
            return LearnerDashboardSettingsWidgetsSectionViewModel(
                userDefaults: defaults,
                configs: configs,
                username: "Riley",
                onConfigsChanged: {}
            )
        }())

        Spacer()
    }
    .padding()
    .background(.backgroundLight)
    .tint(.yellow)
}
