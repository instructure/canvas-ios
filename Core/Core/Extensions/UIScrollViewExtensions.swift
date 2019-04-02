//
// Copyright (C) 2019-present Instructure, Inc.
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

<<<<<<< HEAD
import Foundation

extension UIScrollView {
    /// Whether or not the scroll view has reached the bottom using a threshold.
    ///
    /// The default `threshold` is 60.
    public func isBottomReached(threshold: CGFloat = 60) -> Bool {
        return contentOffset.y >= contentSize.height - frame.size.height - threshold
    }

    /// get a ratio for content offset based on current orientation that can then be used after device rotation
    public var contentOffsetRatio: CGPoint {
        let w = contentSize.width
        let h = contentSize.height
        let centerX = (contentOffset.x + (frame.size.width / 2.0)) / w
        let centerY = (contentOffset.y + (frame.size.height / 2.0)) / h
        return CGPoint(x: centerX, y: centerY)
    }
}
