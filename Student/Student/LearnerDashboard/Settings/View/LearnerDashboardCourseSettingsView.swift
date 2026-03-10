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

struct LearnerDashboardCourseSettingsView: View {
    @State var viewModel: LearnerDashboardCourseSettingsViewModel
    @Environment(\.dynamicTypeSize) var dynamicTypeSize

    var body: some View {
        VStack(spacing: 8) {
            Text("Widgets", bundle: .core)
                .foregroundStyle(.textDarkest)
                .font(.regular14, lineHeight: .fit)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)

            VStack(spacing: 16) {
                ForEach(viewModel.configs) { config in
                    settingCard(config: config)
                }
            }
        }
    }

    @ViewBuilder
    private func settingCard(config: Config) -> some View {
        let binding = Binding {
            config.isVisible
        } set: {
            viewModel.toggleVisibility(of: config, to: $0)
        }

        VStack(spacing: 0) {
            HStack(spacing: 8) {
                buttons(config: config)
                    .tint(.accentColor)

                InstUI.Toggle(isOn: binding) {
                    Text(config.id.settingsTitle(username: viewModel.username))
                        .font(.semibold16, lineHeight: .fit)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .accessibilityLabel(String(
                    localized: "\(config.id.settingsTitle(username: viewModel.username)) widget visibility",
                    bundle: .student
                ))
            }
            .padding(.top, 12)
            .padding(.bottom, 14)

            if let subSettings = viewModel.subSettingsViews[config.id] {
                InstUI.Divider()
                    .padding(.horizontal, -16)
                subSettings
                    .padding(.horizontal, -16)
            }
        }
        .padding(.horizontal, 16)
        .elevation(
            .cardLarge,
            background: .backgroundLightest,
            shadowColor: config.isVisible ? .black : .clear
        )
    }

    @ViewBuilder
    private func buttons(config: Config) -> some View {
        let isMoveDownDisabled = viewModel.isMoveDownDisabled(of: config)
        let isMoveUpDisabled = viewModel.isMoveUpDisabled(of: config)
        let allButtonsDisabled = isMoveDownDisabled && isMoveUpDisabled

        HStack(spacing: 4) {
            Button {
                viewModel.moveUp(config)
            } label: {
                Image.chevronDown
                    .resizable()
                    .scaledFrame(size: 24)
                    .rotationEffect(.degrees(180))
            }
            .disabled(isMoveUpDisabled)
            .accessibilityLabel(String(
                localized: "Move \(config.id.settingsTitle(username: viewModel.username)) widget up",
                bundle: .student
            ))

            InstUI.Divider()
                .padding(.vertical, 4)

            Button {
                viewModel.moveDown(config)
            } label: {
                Image.chevronDown
                    .resizable()
                    .scaledFrame(size: 24)
            }
            .disabled(isMoveDownDisabled)
            .accessibilityLabel(String(
                localized: "Move \(config.id.settingsTitle(username: viewModel.username)) widget down",
                bundle: .student
            ))
        }
        .padding(.horizontal, 8)
        .fixedSize(horizontal: false, vertical: true)
        .elevation(
            .cardSmall,
            background: allButtonsDisabled ? .backgroundLight : .backgroundLightest,
            shadowColor: allButtonsDisabled ? .clear : .black
        )
    }

    init(viewModel: LearnerDashboardCourseSettingsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }
}

extension LearnerDashboardCourseSettingsView {
    typealias Config = DashboardWidgetConfig
}

#Preview {
    VStack {
        LearnerDashboardCourseSettingsView(viewModel: {
            let defaults = SessionDefaults.fallback
            let configs: [DashboardWidgetConfig] = [
                .init(id: .helloWidget, order: 0, isVisible: true),
                .init(id: .coursesAndGroups, order: 1, isVisible: false)
            ]
            return LearnerDashboardCourseSettingsViewModel(
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
