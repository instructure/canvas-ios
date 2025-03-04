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
                ForEach(viewModel.settingsGroups, id: \.groupTitle) { group in
                    getGroupView(group: group)
                }
            }
        }
        .navigationBarTitleView(String(localized: "Settings", bundle: .core))
    }

    private func getGroupView(group: SettingsGroup) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            getGroupTitleView(title: group.groupTitle)

            ForEach(group.items, id: \.id) { groupItem in
                VStack(alignment: .leading, spacing: 0) {
                    Separator()

                    getGroupItem(item: groupItem)

                    if (groupItem.title == group.items.last?.title) {
                        Separator()
                    }
                }
            }
        }
    }

    private func getGroupTitleView(title: String) -> some View {
        return Text(title)
            .font(.regular14)
            .foregroundStyle(Color.textDark)
            .padding(.horizontal, 12)
            .padding(.top, 12)
            .padding(.bottom, 4)
    }

    private func getGroupItem(item: SettingsGroupItem) -> some View {
        return Button {
            item.onSelect(controller)
        } label: {
            HStack(alignment: .center, spacing: 0) {
                Text(item.title)
                    .font(.regular17)
                    .foregroundStyle(Color.textDarkest)

                Spacer()

                if let value = item.valueLabel {
                    Text(value)
                        .font(.bold17)
                        .foregroundStyle(Color.textDark)
                }

                if let icon = item.discloserIndicator {
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
