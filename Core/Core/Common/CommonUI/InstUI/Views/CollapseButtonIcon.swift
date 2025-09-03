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

extension InstUI {

    public struct CollapseButtonIcon: View {

        private let size: CGFloat
        @Binding private var isExpanded: Bool

        public init(
            size: CGFloat = Image.defaultIconSize,
            isExpanded: Binding<Bool>
        ) {
            self.size = size
            self._isExpanded = isExpanded
        }

        public var body: some View {
            Image.chevronDown
                .scaledIcon(size: size)
                .foregroundStyle(.textDark)
                .rotationEffect(.degrees(isExpanded ? 180 : 0))
        }
    }
}
