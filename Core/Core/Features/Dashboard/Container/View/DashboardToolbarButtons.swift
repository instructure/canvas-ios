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

import Combine
import SwiftUI

@available(iOS, introduced: 26, message: "Legacy version exists")
public struct DashboardOptionsMenu: View {
    @Environment(\.viewController) private var viewController
    private let offlineModeViewModel: OfflineModeViewModel
    private let onSettingsTapped: () -> Void
    private let environment: AppEnvironment

    public init(
        offlineModeViewModel: OfflineModeViewModel,
        onSettingsTapped: @escaping () -> Void,
        environment: AppEnvironment = .shared
    ) {
        self.offlineModeViewModel = offlineModeViewModel
        self.onSettingsTapped = onSettingsTapped
        self.environment = environment
    }

    public var body: some View {
        Menu {
            Button(.init("Manage Offline Content", bundle: .core)) {
                if offlineModeViewModel.isOffline {
                    UIAlertController.showItemNotAvailableInOfflineAlert()
                } else {
                    environment.router.route(
                        to: "/offline/sync_picker",
                        from: viewController,
                        options: .modal(isDismissable: false, embedInNav: true)
                    )
                }
            }
            .identifier("Dashboard.manageOfflineButton")

            Button(.init("Dashboard Settings", bundle: .core)) {
                guard viewController.value.presentedViewController == nil else {
                    viewController.value.presentedViewController?.dismiss(animated: true)
                    return
                }
                onSettingsTapped()
            }
            .identifier("Dashboard.settingsButton")
        } label: {
            Image.moreSolid
        }
        .accessibilityLabel(Text("Dashboard Options", bundle: .core))
        .identifier("Dashboard.optionsButton")
    }
}

@available(iOS, deprecated: 26, message: "Non-legacy version exists")
public struct DashboardOptionsButton: View {
    @Environment(\.viewController) private var viewController
    @Binding private var isShowingDialog: Bool
    private let offlineModeViewModel: OfflineModeViewModel
    private let onSettingsTapped: () -> Void
    private let environment: AppEnvironment

    public init(
        isShowingDialog: Binding<Bool>,
        offlineModeViewModel: OfflineModeViewModel,
        onSettingsTapped: @escaping () -> Void,
        environment: AppEnvironment = .shared
    ) {
        self._isShowingDialog = isShowingDialog
        self.offlineModeViewModel = offlineModeViewModel
        self.onSettingsTapped = onSettingsTapped
        self.environment = environment
    }

    public var body: some View {
        Button {
            guard viewController.value.presentedViewController == nil else {
                viewController.value.presentedViewController?.dismiss(animated: true)
                return
            }

            isShowingDialog.toggle()
        } label: {
            Image.moreSolid
                .foregroundStyle(Color(Brand.shared.navTextColor))
        }
        .frame(width: 44, height: 44).padding(.trailing, -6)
        .accessibilityLabel(Text("Dashboard Options", bundle: .core))
        .identifier("Dashboard.optionsButton")
        .confirmationDialog("", isPresented: $isShowingDialog) {
            Button {
                if offlineModeViewModel.isOffline {
                    UIAlertController.showItemNotAvailableInOfflineAlert()
                } else {
                    environment.router.route(
                        to: "/offline/sync_picker",
                        from: viewController,
                        options: .modal(isDismissable: false, embedInNav: true)
                    )
                }
            } label: {
                Text("Manage Offline Content", bundle: .core)
            }
            .identifier("Dashboard.manageOfflineButton")

            Button {
                guard viewController.value.presentedViewController == nil else {
                    viewController.value.presentedViewController?.dismiss(animated: true)
                    return
                }
                onSettingsTapped()
            } label: {
                Text("Dashboard Settings", bundle: .core)
            }
            .identifier("Dashboard.settingsButton")
        }
    }
}

@available(iOS, introduced: 26, message: "Legacy version exists")
public struct DashboardSettingsButton: View {
    @Environment(\.viewController) private var viewController
    private let onTapped: () -> Void

    public init(onTapped: @escaping () -> Void) {
        self.onTapped = onTapped
    }

    public var body: some View {
        Button {
            guard viewController.value.presentedViewController == nil else {
                viewController.value.presentedViewController?.dismiss(animated: true)
                return
            }

            onTapped()
        } label: {
            Image.settingsSolid
        }
        .accessibilityLabel(Text("Dashboard settings", bundle: .core))
        .identifier("Dashboard.settingsButton")
    }
}

@available(iOS, deprecated: 26, message: "Non-legacy version exists")
public struct LegacyDashboardSettingsButton: View {
    @Environment(\.viewController) private var viewController
    private let onTapped: () -> Void

    public init(onTapped: @escaping () -> Void) {
        self.onTapped = onTapped
    }

    public var body: some View {
        Button {
            guard viewController.value.presentedViewController == nil else {
                viewController.value.presentedViewController?.dismiss(animated: true)
                return
            }

            onTapped()
        } label: {
            Image.settingsLine
                .foregroundStyle(Color(Brand.shared.navTextColor))
        }
        .frame(width: 44, height: 44).padding(.trailing, -6)
        .accessibilityLabel(Text("Dashboard settings", bundle: .core))
        .identifier("Dashboard.settingsButton")
    }
}
