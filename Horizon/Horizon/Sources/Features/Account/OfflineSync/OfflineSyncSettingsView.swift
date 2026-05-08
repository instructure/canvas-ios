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
import HorizonUI
import SwiftUI

struct OfflineSyncSettingsView: View {
    @State var viewModel: OfflineSyncSettingsViewModel
    @Environment(\.viewController) private var viewController
    @AccessibilityFocusState private var focusedElementID: String?
    private let syncFrequencyFilterID = "syncFrequencyFilterID"

    var body: some View {
        ZStack {
            Color.huiColors.surface.pagePrimary.edgesIgnoringSafeArea(.all)
            ScrollView {
                VStack(alignment: .leading, spacing: .huiSpaces.space32) {
                    manageAccountButton
                    autoSyncSection
                    if viewModel.isAutoSyncEnabled {
                        frequencySection
                        wifiView
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
                .padding([.horizontal, .top], .huiSpaces.space32)
                .padding(.bottom, .huiSpaces.space48)
                .animation(.default, value: viewModel.isAutoSyncEnabled)
            }
            .background(Color.huiColors.surface.pageSecondary)
            .huiCornerRadius(level: .level5, corners: [.topLeft, .topRight])
        }
        .safeAreaInset(edge: .top, spacing: .zero) { navigationBar }
        .ignoresSafeArea(edges: .bottom)
        .background(Color.huiColors.surface.pagePrimary)
        .alert(
            viewModel.wifiConfirmationTitle,
            isPresented: $viewModel.isShowingWifiConfirmation
        ) {
            Button(String(localized: "Cancel", bundle: .horizon), role: .cancel) {}
            Button(viewModel.wifiConfirmationButtonTitle) {
                viewModel.confirmWifiSyncChange()
            }
        } message: {
            Text(viewModel.wifiConfirmationMessage)
        }
    }

    private var manageAccountButton: some View {
        HorizonUI.PrimaryButton(
            String(localized: "Manage offline content"),
            type: .black,
            fillsWidth: true,
            trailing: HorizonUI.icons.arrowForward,

        ) {}
    }

    private var autoSyncSection: some View {
        VStack(alignment: .leading, spacing: .huiSpaces.space8) {
            Text("Sync settings")
                .frame(maxWidth: .infinity, alignment: .leading)
                .huiTypography(.labelLargeBold)
                .foregroundStyle(Color.huiColors.text.body)
                .accessibilityAddTraits(.isHeader)
            HorizonUI.Controls.ToggleItem(
                isOn: $viewModel.isAutoSyncEnabled,
                title: String(localized: "Auto content sync", bundle: .horizon)
            )
            Text(
                """
                Enabling auto content sync downloads your selected content based on the settings below.
                This happens even if the app isn't running.
                If you switch this off, synchronization stops, but your downloaded content won't be deleted.
                """
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .multilineTextAlignment(.leading)
            .huiTypography(.p2)
            .foregroundStyle(Color.huiColors.text.body)
        }
    }

    private var frequencySection: some View {
        VStack(alignment: .leading, spacing: .huiSpaces.space8) {
            Text("Sync Frequency", bundle: .horizon)
                .huiTypography(.labelLargeBold)
                .foregroundStyle(Color.huiColors.text.body)
                .accessibilityAddTraits(.isHeader)
            FilterView(
                items: CourseSyncFrequency.allCases.map { OptionModel(id: "\($0.rawValue)", name: $0.stringValue) },
                selectedOption: OptionModel(id: "\(viewModel.syncFrequency.rawValue)", name: viewModel.syncFrequency.stringValue)
            ) { selected in
                if let selected,
                   let raw = Int(selected.id),
                   let frequency = CourseSyncFrequency(rawValue: raw) {
                    viewModel.syncFrequency = frequency
                    restoreFocusIfNeeded(after: 1)
                }
            }
            .id(syncFrequencyFilterID)
            .accessibilityFocused($focusedElementID, equals: syncFrequencyFilterID)

            Text(
                "Specify how often content synchronizes. The system downloads your selected content based on this frequency.",
                bundle: .horizon
            )
            .huiTypography(.p2)
            .foregroundStyle(Color.huiColors.text.body)
            .multilineTextAlignment(.leading)
        }
    }

    private var wifiView: some View {
        VStack(alignment: .leading, spacing: .huiSpaces.space8) {
            HorizonUI.Controls.ToggleItem(
                isOn: Binding(
                    get: { viewModel.isWifiOnlySyncEnabled },
                    set: { viewModel.wifiOnlySyncToggled(newValue: $0) }
                ),
                title: String(localized: "Sync content over Wi-Fi only", bundle: .horizon)
            )
            Text(
                "If you enable this setting, content only synchronizes when your device connects to a Wi-Fi network. Otherwise, the sync is postponed until a Wi-Fi network is available.",
                bundle: .horizon
            )
            .huiTypography(.p2)
            .foregroundStyle(Color.huiColors.text.body)
        }
    }

    // MARK: - Private helpers

    private func restoreFocusIfNeeded(after: Double) {
        DispatchQueue.main.asyncAfter(deadline: .now() + after) {
            focusedElementID = syncFrequencyFilterID
        }
    }

    // MARK: - Navigation Bar

    private var navigationBar: some View {
        ZStack {
            Text("Offline settings", bundle: .horizon)
                .huiTypography(.h3)
                .foregroundStyle(Color.huiColors.text.title)
                .frame(maxWidth: .infinity, alignment: .center)
                .accessibilityAddTraits(.isHeader)

            HStack(spacing: 0) {
                HorizonUI.IconButton(
                    HorizonUI.icons.arrowBack,
                    type: .gray,
                    isSmall: false
                ) {
                    viewModel.navigateBack(viewController: viewController)
                }
                .frame(width: 44, height: 44)
                .padding(.leading, .huiSpaces.space24)
                .accessibilityLabel(String(localized: "Back"))
                Spacer()
            }
        }
        .padding(.bottom, .huiSpaces.space8)
    }
}

#if DEBUG
#Preview {
    OfflineSyncSettingsAssembly.makePreview()
}
#endif
