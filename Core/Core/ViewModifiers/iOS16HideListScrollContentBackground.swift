//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

@available(iOS, introduced: 16.0, obsoleted: 16.1)
struct IOS16HideListScrollContentBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.scrollContentBackground(.hidden)
    }
}

public extension View {
    /**
     This view modifier fixes the iOS 16.0 only bug where the List scroll content background is not hidden by default.
     */
    @ViewBuilder
    func iOS16HideListScrollContentBackground() -> some View {
        if #available(iOS 16, *) {
            self.modifier(IOS16HideListScrollContentBackgroundModifier())
        } else {
            self
        }
    }
}

public extension View {
    /**
     This view modifier fixes the iOS 16.0 only bug where the List scroll content background is not hidden by default.
     */
    @ViewBuilder
    func listSystemBackgroundColor() -> some View {
        self
            .iOS16HideListScrollContentBackground()
            .background(Color.backgroundLightest.ignoresSafeArea())
    }
}
