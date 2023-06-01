//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

struct CourseSyncSettingsView: View {
    @ObservedObject private var viewModel: CourseSyncSettingsViewModel
    @Environment(\.viewController) private var viewController

    init(viewModel: CourseSyncSettingsViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                autoSyncToggle

                ZStack {
                    if viewModel.isAllSettingsVisible {
                        otherSettings
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
                .frame(maxWidth: .infinity)
                .clipped()
                .animation(.default, value: viewModel.isAllSettingsVisible)
            }
        }
        .background(Color.backgroundLightest)
        .navigationTitle(Text("Synchronization", bundle: .core))
        .confirmationAlert(isPresented: $viewModel.isShowingConfirmationDialog,
                           presenting: viewModel.confirmAlert)
    }

    @ViewBuilder
    private var autoSyncToggle: some View {
        let binding = Binding {
            viewModel.isAutoContentSyncEnabled.value
        } set: {
            viewModel.isAutoContentSyncEnabled.accept($0)
        }

        toggle(text: Text("Auto Content Sync", bundle: .core),
               isOn: binding)
        .accessibilityHint(viewModel.labels.autoContentSync)
        Divider()
        description(viewModel.labels.autoContentSync)
    }

    @ViewBuilder
    private var otherSettings: some View {
        let wifiOnlyBinding = Binding {
            viewModel.isWifiOnlySyncEnabled.value
        } set: { newValue in
            viewModel.isWifiOnlySyncEnabled.accept(newValue)
        }

        VStack(spacing: 0) {
            Divider().padding(.horizontal, -16)
            Button {
                viewModel.syncFrequencyDidTap.accept(viewController)
            } label: {
                HStack(spacing: 0) {
                    Text("Sync Frequency", bundle: .core)
                        .foregroundColor(.textDarkest)
                        .font(.semibold16, lineHeight: .fit)
                        .padding(.top, 14)
                        .padding(.bottom, 17)
                    Spacer(minLength: 0)
                    Text(viewModel.syncFrequencyLabel)
                        .foregroundColor(.textDark)
                        .font(.regular14)
                        .padding(.trailing, 15)
                    InstDisclosureIndicator()
                }
                .padding(.horizontal, 16)
                .accessibilityHint(viewModel.labels.syncFrequency)
            }
            Divider()
            description(viewModel.labels.syncFrequency)
            Divider()
            toggle(text: Text("Sync Content Over Wi-Fi Only", bundle: .core),
                   isOn: wifiOnlyBinding)
            .accessibilityHint(viewModel.labels.wifiOnlySync)
            .animation(.default, value: viewModel.isWifiOnlySyncEnabled.value)
            Divider()
            description(viewModel.labels.wifiOnlySync)
        }
    }

    private func description(_ text: String) -> some View {
        Text(text)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 12)
            .padding(.bottom, 32)
            .padding(.horizontal, 16)
            .foregroundColor(.textDark)
            .font(.regular14, lineHeight: .fit)
            .accessibilityHidden(true)
    }

    private func toggle(text: Text, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            text
                .font(.semibold16)
                .foregroundColor(.textDarkest)
        }
        .toggleStyle(SwitchToggleStyle(tint: Color(Brand.shared.primary)))
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }
}

#if DEBUG

struct CourseSyncSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        CourseSyncSettingsAssembly.makePreview()
    }
}

#endif
