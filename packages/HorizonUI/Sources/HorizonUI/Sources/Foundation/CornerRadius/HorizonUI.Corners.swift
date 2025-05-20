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

public extension HorizonUI {
    struct Corners: OptionSet, Sendable {
        public let rawValue: Int
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        public static let topLeft = Corners(rawValue: 1 << 0)
        public static let topRight = Corners(rawValue: 1 << 1)
        public static let bottomLeft = Corners(rawValue: 1 << 2)
        public static let bottomRight = Corners(rawValue: 1 << 3)

        public static let all: Corners = [.topLeft, .topRight, .bottomLeft, .bottomRight]
        public static let top: Corners = [.topLeft, .topRight]
        public static let bottom: Corners = [.bottomLeft, .bottomRight]
        public static let left: Corners = [.topLeft, .bottomLeft]
        public static let right: Corners = [.topRight, .bottomRight]
    }
}
