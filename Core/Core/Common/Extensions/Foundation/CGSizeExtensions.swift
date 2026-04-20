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

    /// Returns a new size that fits within the specified maximum size while preserving the original aspect ratio.
    ///
    /// - Parameters:
    ///   - maxSize: The maximum allowed size. The returned size will not exceed this width or height.
    /// - Returns: A size scaled down proportionally to fit within `maxSize`. If the receiver already fits within
    ///   `maxSize`, the original size is returned. If the receiver has a non-positive width or height, `.zero` is returned.
    /// - Discussion:
    ///   - If both dimensions of the receiver are within the bounds of `maxSize`, no scaling is applied.
    ///   - If either dimension exceeds `maxSize`, the size is uniformly scaled by the smaller of the width and height ratios
    ///     (`maxSize.width / width` and `maxSize.height / height`) to ensure the result fits within both constraints.
    ///   - Maintains the aspect ratio of the original size.
    public func downscaledToFit(_ maxSize: CGSize) -> CGSize {
        guard width > 0, height > 0 else { return .zero }
        guard width > maxSize.width || height > maxSize.height else { return self }

        let widthRatio = maxSize.width / width
        let heightRatio = maxSize.height / height
        let scale = min(widthRatio, heightRatio)
        return CGSize(width: width * scale, height: height * scale)
    }
}
