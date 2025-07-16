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
import SwiftUI

struct RubricRectangle<Content: View>: View {
    @Binding private var isOn: Bool
    private let content: Content
    private let containerFrame: CGRect

    init(
        isOn: Binding<Bool>,
        containerFrame: CGRect = .null,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self._isOn = isOn
        self.containerFrame = containerFrame
    }

    var body: some View {
        content
            .font(.regular16)
            .foregroundColor(isOn ? .textLightest : .textDarkest)
            .frame(minWidth: 42, minHeight: 38, maxHeight: 38)
            .background(isOn ?
                RoundedRectangle(cornerRadius: 4).fill(.tint) :
                nil
            )
            .background(!isOn ?
                RoundedRectangle(cornerRadius: 4).stroke(Color.borderMedium) :
                nil
            )
            .accessibility(addTraits: isOn ? [.isButton, .isSelected] : .isButton)
            .onTapGesture { isOn.toggle() }
    }
}
