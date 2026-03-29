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

import Foundation

extension CGSize {
    public var isZero: Bool { self == .zero }
    public var isSwipingLeft: Bool { width < 0 }
    public var isHorizontalSwipe: Bool { abs(width) > abs(height) }

    public func contained(in maxSize: CGSize) -> CGSize {
        guard width > 0, height > 0 else { return .zero }
        guard width > maxSize.width || height > maxSize.height else { return self }

        let widthRatio = maxSize.width / width
        let heightRatio = maxSize.height / height
        let scale = min(widthRatio, heightRatio)
        return CGSize(width: width * scale, height: height * scale)
    }
}
