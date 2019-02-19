//
// Copyright (C) 2017-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

public struct Graphic {
    public let icon: Icon
    public let filled: Bool
    public let size: Icon.Size

    public init(icon: Icon, filled: Bool = false, size: Icon.Size = .standard) {
        self.icon = icon
        self.filled = filled
        self.size = size
    }

    public var image: UIImage {
        return .icon(icon, filled: filled, size: size)
    }
}

extension Graphic: Equatable {}
public func ==(lhs: Graphic, rhs: Graphic) -> Bool {
    return lhs.icon == rhs.icon &&
        lhs.filled == rhs.filled &&
        lhs.size == rhs.size
}
