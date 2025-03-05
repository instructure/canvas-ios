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
        Button {
            viewModel.onSelect(controller)
        } label: {
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
}

#Preview {
    let viewModel = SettingsGroupItemViewModel(title: "Appearance", valueLabel: "Light", id: .appearance) {_ in }
    SettingsGroupItemView(viewModel: viewModel)
}
