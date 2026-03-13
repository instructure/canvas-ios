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

import Core
import SwiftUI

struct LearnerDashboardSettingsScreen: View {
    @Environment(\.viewController) private var viewController
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: LearnerDashboardSettingsViewModel
    @State private var showSwitchAlert = false

    init(viewModel: LearnerDashboardSettingsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                newDashboardToggle
                dashboardColorSelector
                widgetsSection
                feedbackSection
            }
            .paddingStyle(.horizontal, .standard)
            .paddingStyle(.bottom, .standard)
        }
        .background(Color.backgroundLight.ignoresSafeArea())
        .navigationTitle(String(localized: "Customize Dashboard", bundle: .student), style: .modal)
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $showSwitchAlert) {
            switchDashboardAlert
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { dismiss() }) {
                    Text("Done", bundle: .student)
                        .font(.scaledRestrictly(.semibold16))
                        .foregroundStyle(.brandPrimary)
                }
                .identifier("DashboardSettings.doneButton")
            }
        }
    }

    private var newDashboardToggle: some View {
        let isOnBinding = Binding(
            get: { viewModel.useNewLearnerDashboard },
            set: { _ in showSwitchAlert = true }
        )
        return InstUI.Toggle(isOn: isOnBinding) {
            Text("New Mobile Dashboard", bundle: .student)
                .font(.semibold16)
                .foregroundStyle(Color.textDarkest)
        }
        .padding(.vertical, 8)
        .accessibilityIdentifier("DashboardSettings.newDashboardToggle")
    }

    private var dashboardColorSelector: some View {
        VStack(alignment: .leading, spacing: 0) {
            LearnerDashboardColorSelectorView(selectedColor: $viewModel.mainColor, colors: viewModel.colors)
            InstUI.Divider()
        }
    }

    private var widgetsSection: some View {
        LearnerDashboardSettingsWidgetsSectionView(viewModel: viewModel.courseSettingsViewModel)
    }

    @ViewBuilder
    private var feedbackSection: some View {
        VStack(spacing: 16) {
            Text("What do you think of the new dashboard?", bundle: .student)
                .font(.regular14, lineHeight: .fit)
                .foregroundStyle(.textDarkest)

            Button {
                viewModel.letUsKnow(from: viewController.value)
            } label: {
                InstUI.PillContent(
                    title: String(localized: "Let us know!", bundle: .student),
                    trailingIcon: .externalLinkLine,
                    size: .height30
                )
            }
            .buttonStyle(.pillTintOutlined)
            .tint(viewModel.mainColor)
        }
        .frame(maxWidth: .infinity)
    }

    private var switchDashboardAlert: Alert {
        DashboardSwitchAlert.makeAlert(isEnabling: false) {
            viewModel.switchToClassicDashboard(viewController: viewController.value)
        }
    }
}

#if DEBUG

#Preview("New Dashboard Enabled") {
    LearnerDashboardSettingsScreen(
        viewModel: {
            var defaults = SessionDefaults.fallback
            defaults.preferNewLearnerDashboard = true
            let configs = EditableWidgetIdentifier.makeDefaultConfigs()
            let courseSettingsVM = LearnerDashboardSettingsWidgetsSectionViewModel(
                userDefaults: defaults,
                configs: configs,
                username: "Riley",
                onConfigsChanged: {}
            )
            return LearnerDashboardSettingsViewModel(defaults: defaults, colorInteractor: LearnerDashboardColorInteractorLive(defaults: defaults), courseSettingsViewModel: courseSettingsVM)
        }()
    )
}

#Preview("New Dashboard Disabled") {
    LearnerDashboardSettingsScreen(
        viewModel: {
            var defaults = SessionDefaults.fallback
            defaults.preferNewLearnerDashboard = false
            let configs = EditableWidgetIdentifier.makeDefaultConfigs()
            let courseSettingsVM = LearnerDashboardSettingsWidgetsSectionViewModel(
                userDefaults: defaults,
                configs: configs,
                username: "Riley",
                onConfigsChanged: {}
            )
            return LearnerDashboardSettingsViewModel(defaults: defaults, colorInteractor: LearnerDashboardColorInteractorLive(defaults: defaults), courseSettingsViewModel: courseSettingsVM)
        }()
    )
}

#endif
