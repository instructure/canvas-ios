//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
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

import Foundation

extension CGRect {
    
    // Clamps the rect inside of `size`
    // Example:
    //  If your rect is (100, 100), and you pass in (50, 50), the returns rect will be (50x50)
    //  If you pass in an inset of 10, the resulting rect would be (40x40)
    public func clamp(_ size: CGSize, inset: CGFloat = 0.0) -> CGRect {
        var clamped = self
        if clamped.width > size.width {
            clamped.size.width = size.width - inset
        }
        if clamped.height > size.height {
            clamped.size.height = size.height - inset
        }
        return clamped
    }
}
