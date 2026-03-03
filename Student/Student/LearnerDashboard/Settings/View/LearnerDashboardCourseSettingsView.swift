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
    @ScaledMetric private var uiScale: CGFloat = 1

    // Example username for preview and accessibility labels
    let username = "Riley"

    var body: some View {
        VStack(spacing: 8) {
            Text("Widgets", bundle: .core)
                .foregroundStyle(.textDarkest)
                .font(.regular14, lineHeight: .fit)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 16) {
                ForEach(viewModel.visibleConfigs) { config in
                    settingCard(config: config)
                }

                ForEach(viewModel.hiddenConfigs) { config in
                    disabledSettingCard(config: config)
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

                InstUI.Toggle(isOn: binding) {
                    // Example username
                    Text(config.id.title(username: username))
                        .font(.semibold16, lineHeight: .fit)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .accessibilityLabel(String(
                    localized: "\(config.id.title(username: username)) widget visibility",
                    bundle: .student
                ))
            }
            .padding(.top, 12)
            .padding(.bottom, 14)

            InstUI.Divider()
                .padding(.horizontal, -16)

            // Example data
            ForEach(0..<2) { index in
                InstUI.Toggle(isOn: .constant(true)) {
                    Text("Example setting \(index)", bundle: .core)
                        .font(.semibold16, lineHeight: .fit)
                }
                .padding(.top, 12)
                .padding(.bottom, 14)

                if index != 1 {
                    InstUI.Divider()
                }
            }
        }
        .padding(.horizontal, 16)
        .elevation(.cardLarge, background: .backgroundLightest)
    }

    @ViewBuilder
    private func disabledSettingCard(config: Config) -> some View {
        let binding = Binding {
            config.isVisible
        } set: {
            viewModel.toggleVisibility(of: config, to: $0)
        }

        HStack(spacing: 8) {
            disabledButtons

            InstUI.Toggle(isOn: binding) {
                Text(config.id.title(username: username))
                    .font(.semibold16, lineHeight: .fit)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .accessibilityLabel(String(
                localized: "\(config.id.title(username: username)) widget visibility",
                bundle: .student
            ))
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 14)
        .background(.backgroundLightest)
        .cornerRadius(InstUI.Styles.Elevation.Shape.cardLarge.cornerRadius)
    }

    @ViewBuilder
    private func buttons(config: Config) -> some View {
        HStack(spacing: 4) {
            Button {
                viewModel.moveUp(config)
            } label: {
                Image.chevronDown
                    .resizable()
                    .frame(width: 24 * uiScale, height: 24 * uiScale)
                    .rotationEffect(.degrees(180))
            }
            .disabled(viewModel.visibleConfigs.first == config)
            .accessibilityLabel(String(
                localized: "Move \(config.id.title(username: username)) widget up",
                bundle: .student
            ))

            InstUI.Divider()
                .padding(.vertical, 4)

            Button {
                viewModel.moveDown(config)
            } label: {
                Image.chevronDown
                    .resizable()
                    .frame(width: 24 * uiScale, height: 24 * uiScale)
            }
            .disabled(viewModel.visibleConfigs.last == config)
            .accessibilityLabel(String(
                localized: "Move \(config.id.title(username: username)) widget down",
                bundle: .student
            ))
        }
        .padding(.horizontal, 8)
        .fixedSize(horizontal: false, vertical: true)
        .elevation(.cardSmall, background: .backgroundLightest)
    }

    @ViewBuilder
    private var disabledButtons: some View {
        HStack(spacing: 4) {
            Image.chevronDown
                .resizable()
                .frame(width: 24 * uiScale, height: 24 * uiScale)
                .foregroundStyle(.disabledGray)
                .rotationEffect(.degrees(180))

            InstUI.Divider()
                .padding(.vertical, 4)

            Image.chevronDown
                .resizable()
                .frame(width: 24 * uiScale, height: 24 * uiScale)
                .foregroundStyle(.disabledGray)
        }
        .padding(.horizontal, 8)
        .fixedSize(horizontal: false, vertical: true)
        .background(
            .backgroundLight,
            in: RoundedRectangle(cornerRadius: InstUI.Styles.Elevation.Shape.cardSmall.cornerRadius)
        )
        .accessibilityHidden(true)
    }

    init() {
        self.viewModel = .init(configs: .preview)
    }
}

extension LearnerDashboardCourseSettingsView {
    typealias Config = DashboardWidgetConfig
}

extension Array where Element == DashboardWidgetConfig {
    static let preview: [DashboardWidgetConfig] = [
        .init(id: .helloWidget, order: 0, isVisible: true),
        .init(id: .coursesAndGroups, order: 1, isVisible: false),
        .init(id: .conferences, order: 2, isVisible: true)
    ]
}

#Preview {
    VStack {
        LearnerDashboardCourseSettingsView()

        Spacer()
    }
    .padding()
    .background(.backgroundLight)
}
