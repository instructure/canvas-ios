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
import Core

public struct ProfileSettingsView: View {
    @ObservedObject private var viewModel: ProfileSettingsViewModel
    @Environment(\.viewController) private var controller
    @ScaledMetric private var uiScale: CGFloat = 1

    public init(viewModel: ProfileSettingsViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(viewModel.settingsGroups, id: \.viewModel.title) { group in
                    group
                }
            }
        }
        .background(Color.backgroundLightest)
        .navigationBarTitleView(String(localized: "Settings", bundle: .core))
    }
}

#if DEBUG

struct ProfileSettingsView_Previews: PreviewProvider {
    static let env = PreviewEnvironment()
    static let viewModel = ProfileSettingsViewModel(
        inboxSettingsInteractor: InboxSettingsInteractorPreview(),
        offlineInteractor: OfflineModeInteractorMock(),
        environment: env
    )

    static var previews: some View {
        ProfileSettingsView(viewModel: viewModel)
    }
}

#endif
