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

struct SettingsGroupItemView: View {
    @Environment(\.viewController) private var controller
    @ScaledMetric private var uiScale: CGFloat = 1

    @ObservedObject var viewModel: SettingsGroupItemViewModel

    var body: some View {
        if !viewModel.isHidden {
            if viewModel.isLink {
                Button {
                    viewModel.onSelect(controller)
                } label: {
                    itemView
                }
                .disabled(viewModel.disabled)
                .opacity(viewModel.disabled ? 0.6 : 1)
                .accessibilityAddTraits(.isLink)
                .accessibilityRemoveTraits(.isButton)
            } else {
                Button {
                    viewModel.onSelect(controller)
                } label: {
                    itemView
                }
                .disabled(viewModel.disabled)
                .opacity(viewModel.disabled ? 0.6 : 1)
            }
        }
    }

    private var itemView: some View {
        HStack(alignment: .center, spacing: 0) {
            Text(viewModel.title)
                .font(.regular17)
                .foregroundStyle(Color.textDarkest)

            Spacer()

            if let value = viewModel.valueLabel {
                Text(value)
                    .font(.bold17)
                    .foregroundStyle(Color.textDark)
            }

            if let icon = viewModel.discloserIndicator {
                icon
                    .resizable()
                    .frame(width: 16 * uiScale.iconScale, height: 16 * uiScale.iconScale)
                    .foregroundStyle(Color.textDark)
                    .padding(.vertical, 8)
                    .padding(.leading, 4)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 6)
    }
}

#if DEBUG

struct SettingsGroupItemView_Previews: PreviewProvider {
    static let env = PreviewEnvironment()
    static let viewModel = SettingsGroupItemViewModel.makePreview(title: "Setting 1", valueLabel: "Enabled")

    static var previews: some View {
        SettingsGroupItemView(viewModel: viewModel)
    }
}

#endif
