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

public struct PrivacySettingsScreen: View {

    private let viewModel: PrivacySettingsViewModel

    public init(viewModel: PrivacySettingsViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        BaseScreen(state: viewModel.state, config: .notRefreshable) { _ in
            VStack(alignment: .leading, spacing: 0) {
                AUI.ToggleCell(
                    label: Text("Anonymous Application Analytics", bundle: .core),
                    value: viewModel.isAnalyticsEnabledBinding,
                    dividerStyle: .hidden
                )
                AUI.LabelCell(label: descriptionLabel)
            }
        }
        .navigationTitle(String(localized: "Privacy Settings", bundle: .core), style: .modal)
        .snackBar(viewModel: viewModel.snackBar)
        .onAppear { viewModel.loadConsent() }
    }

    private var descriptionLabel: some View {
        Text("""
            Share anonymous data about app performance and feature use. \
            This helps us fix bugs and improve the overall application experience. \
            We do not collect personal identifiers.
            """, bundle: .core)
        .font(.regular14)
        .foregroundColor(.textDark)
    }
}
