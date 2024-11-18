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
import Core

struct ModuleBottomNavBar: View {
    private let iconNames = ModuleBottomsType.allCases
    var onSelect: (ModuleBottomsType) -> Void

    var body: some View {
        HStack(spacing: 20) {
            ForEach(iconNames, id: \.self) { icon in
                buttonView(icon: icon)
            }
        }
        .padding(5)
        .background(Color.textLightest)
        .clipShape(.capsule)
    }

    private func buttonView(icon: ModuleBottomsType) -> some View {
        Button {
            onSelect(icon)
        } label: {
            labelButton(icon: icon)
        }
    }

    private func labelButton(icon: ModuleBottomsType) -> some View {
        Circle()
            .fill(Color.disabledGray.opacity(0.2))
            .frame(width: 50, height: 50)
            .overlay(
                Image(systemName: icon.imageName)
                    .foregroundStyle(Color.textDarkest)
            )
    }
}

#if DEBUG
#Preview {
    ModuleBottomNavBar(onSelect: { _ in })
}
#endif
