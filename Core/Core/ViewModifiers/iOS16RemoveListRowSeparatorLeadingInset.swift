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

@available(iOS, introduced: 16.0, obsoleted: 16.1)
struct RemoveListRowSeparatorLeadingInset: ViewModifier {
    func body(content: Content) -> some View {
        content.alignmentGuide(.listRowSeparatorLeading) { viewDimensions in
            return -viewDimensions.width
        }
    }
}

public extension View {
    @ViewBuilder
    func removeListRowSeparatorLeadingInset() -> some View {
        if #available(iOS 16, *) {
            self.modifier(RemoveListRowSeparatorLeadingInset())
        } else {
            self
        }
    }
}
