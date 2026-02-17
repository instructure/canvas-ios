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

struct LearnerDashboardSettingsView: View {
    @State private var viewModel: LearnerDashboardSettingsViewModel
    @Environment(\.viewController) private var viewController
    @State private var showSwitchAlert = false

    init(viewModel: LearnerDashboardSettingsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                toggle(
                    text: Text("New Mobile Dashboard", bundle: .student),
                    isOn: Binding(
                        get: { viewModel.useNewLearnerDashboard },
                        set: { _ in
                            showSwitchAlert = true
                        }
                    )
                )
                Spacer()
            }
            .paddingStyle(.horizontal, .standard)
        }
        .background(Color.backgroundLightest.ignoresSafeArea())
        .navigationTitle(String(localized: "Customize Dashboard", bundle: .student), style: .modal)
        .alert(isPresented: $showSwitchAlert) {
            switchDashboardAlert
        }
    }

    private func toggle(text: Text, isOn: Binding<Bool>) -> some View {
        InstUI.Toggle(isOn: isOn) {
            text
                .font(.semibold16)
                .foregroundStyle(Color.textDarkest)
        }
        .padding(.vertical, 8)
    }

    private var switchDashboardAlert: Alert {
        DashboardSwitchAlert.makeAlert(isEnabling: false) {
            viewModel.switchToClassicDashboard(viewController: viewController.value)
        }
    }
}

#if DEBUG

#Preview("New Dashboard Enabled") {
    LearnerDashboardSettingsView(
        viewModel: {
            var defaults = SessionDefaults.fallback
            defaults.preferNewLearnerDashboard = true
            return LearnerDashboardSettingsViewModel(defaults: defaults)
        }()
    )
}

#Preview("New Dashboard Disabled") {
    LearnerDashboardSettingsView(
        viewModel: {
            var defaults = SessionDefaults.fallback
            defaults.preferNewLearnerDashboard = false
            return LearnerDashboardSettingsViewModel(defaults: defaults)
        }()
    )
}

#endif
