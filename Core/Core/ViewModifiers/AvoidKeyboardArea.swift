//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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
import Combine

@available(iOSApplicationExtension 13.0, *)
struct AvoidKeyboardArea: ViewModifier {
    @State var height = CGFloat(0)

    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .padding(.bottom, height)
                .onReceive(Publishers.keyboardHeight) { height in
                    let maxY = geometry.frame(in: .global).maxY
                    let distanceToBottom = UIScreen.main.bounds.height - maxY
                    self.height = height - distanceToBottom
                }
        }
    }
}

@available(iOSApplicationExtension 13.0, *)
extension View {
    func avoidKeyboardArea() -> some View {
        modifier(AvoidKeyboardArea())
    }
}
