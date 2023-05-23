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
        Divider()
        description("""
        Enabling the Auto Content Sync will take care of downloading the selected content based on the below \
        settings. The content synchronization will happen even if the application is not running. If the setting is \
        switched off then no synchronization will happen. The already downloaded content will not be deleted.
        """)
    }

    @ViewBuilder
    private var otherSettings: some View {
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
                    Text("Daily", bundle: .core)
                        .foregroundColor(.textDark)
                        .font(.regular14)
                        .padding(.trailing, 15)
                    InstDisclosureIndicator()
                }
                .padding(.horizontal, 16)
            }
            Divider()
            description("Specify the recurrence of the content synchronization. The system will download the selected content based on the frequency specified here.")
            Divider()
            toggle(text: Text("Sync Content Over Wi-Fi Only", bundle: .core),
                   isOn: .constant(true))
            Divider()
            description("""
                    If this setting is enabled the content synchronization will only happen if the device connects \
                    to a Wi-Fi network, otherwise it will be postponed until a Wi-Fi network is available.
                    """)
        }
    }

    private func description(_ text: String) -> some View {
        Text(text)
            .padding(.top, 12)
            .padding(.bottom, 32)
            .padding(.horizontal, 16)
            .foregroundColor(.textDark)
            .font(.regular14, lineHeight: .fit)
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

struct CourseSyncSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        CourseSyncSettingsAssembly.makePreview()
    }
}
