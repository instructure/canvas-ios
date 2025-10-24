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

struct PaginationTransitionModifier: ViewModifier {
    let direction: Edge

    func body(content: Content) -> some View {
        content.transition(
            .asymmetric(
                insertion: .move(edge: direction)
                    .combined(with: .opacity),
                removal: .move(edge: direction == .leading ? .trailing : .leading)
                    .combined(with: .opacity)
            )
        )
    }
}

extension View {
    func paginationTransition(_ direction: Edge) -> some View {
        self.modifier(PaginationTransitionModifier(direction: direction))
    }
}
