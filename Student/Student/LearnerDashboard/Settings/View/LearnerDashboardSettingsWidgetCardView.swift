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

struct LearnerDashboardSettingsWidgetCardView: View {
    let config: DashboardWidgetConfig
    let username: String
    @Binding var isVisible: Bool
    let isMoveUpDisabled: Bool
    let isMoveDownDisabled: Bool
    let onMoveUp: () -> Void
    let onMoveDown: () -> Void
    let subSettingsView: AnyView?

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                buttons

                InstUI.Toggle(isOn: $isVisible) {
                    Text(config.id.settingsTitle(username: username))
                        .font(.semibold16, lineHeight: .fit)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .accessibilityLabel(String(
                    localized: "\(config.id.settingsTitle(username: username)) widget visibility",
                    bundle: .student
                ))
            }
            .padding(.top, 12)
            .padding(.bottom, 14)
            .accessibilityElement(children: .combine)

            if let subSettings = subSettingsView {
                InstUI.Divider()
                    .padding(.horizontal, -16)
                subSettings
                    .padding(.horizontal, -16)
            }
        }
        .paddingStyle(.horizontal, .standard)
        .elevation(
            .cardLarge,
            background: .backgroundLightest,
            isShadowVisible: isVisible
        )
    }

    @ViewBuilder
    private var buttons: some View {
        let allButtonsDisabled = isMoveDownDisabled && isMoveUpDisabled

        HStack(spacing: 4) {
            Button {
                onMoveUp()
            } label: {
                Image.chevronDown
                    .scaledIcon()
                    .rotationEffect(.degrees(180))
            }
            .disabled(isMoveUpDisabled)
            .accessibilityLabel(String(
                localized: "Move \(config.id.settingsTitle(username: username)) widget up",
                bundle: .student
            ))

            InstUI.Divider()
                .padding(.vertical, 4)

            Button {
                onMoveDown()
            } label: {
                Image.chevronDown
                    .scaledIcon()
            }
            .disabled(isMoveDownDisabled)
            .accessibilityLabel(String(
                localized: "Move \(config.id.settingsTitle(username: username)) widget down",
                bundle: .student
            ))
        }
        .padding(.horizontal, 8)
        .fixedSize(horizontal: false, vertical: true)
        .elevation(
            .cardSmall,
            background: allButtonsDisabled ? .backgroundLight : .backgroundLightest,
            isShadowVisible: !allButtonsDisabled
        )
    }
}
