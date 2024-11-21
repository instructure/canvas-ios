//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

struct ModuleNavBarView: View {
    @ObservedObject var viewModel: ModuleBottomNavBarViewModel

    private let contentButtons = ModuleNavBarButtons.contentButtons

    var body: some View {
        HStack(spacing: 0) {
            Button {
                viewModel.didTapPreviousButton()
            } label: {
                iconView(type: .previous).disableWithOpacity(!viewModel.isPreviousButtonEnabled)
            }
            Spacer()
            HStack(spacing: 8) {
                ForEach(contentButtons, id: \.self) { button in
                    buttonView(type: button)
                }
            }
            Spacer()
            Button {
                viewModel.didTapNextButton()
            } label: {
                iconView(type: .next).disableWithOpacity(!viewModel.isNextButtonEnabled)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        // TODO: Replace with predefined Horizon colors
        .background(Color(hexString: "#FBF5ED"))
        .clipShape(.capsule)
    }

    private func buttonView(type: ModuleNavBarButtons) -> some View {
        Button {
            viewModel.didSelectButton(type: type)
        } label: {
            iconView(type: type)
        }
    }

    private func iconView(type: ModuleNavBarButtons) -> some View {
        Circle()
            .fill(Color.disabledGray.opacity(0.2))
            .frame(width: 50, height: 50)
            .overlay(
                type.image.foregroundStyle(Color.textDarkest)
            )
    }
}

// #if DEBUG
// #Preview {
//    ModuleBottomNavBar(onSelect: { _ in }, isPreviousButtonEnabled: .constant(true), isNextButtonEnabled: .constant(true))
// }
// #endif
