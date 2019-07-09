//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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
import CanvasCore

extension UIColor {
    @objc public static func parentRedColor() -> UIColor {
        return UIColor(r: 208, g: 2, b: 27)
    }

    @objc public static func parentYellowColor() -> UIColor {
        return UIColor(r: 245, g: 166, b: 35)
    }

    @objc public static func parentBlueColor() -> UIColor {
        return UIColor(r: 0, g: 150, b: 219)
    }

    @objc public static func parentGreenColor() -> UIColor {
        return UIColor(r: 72, g: 175, b: 73)
    }

    @objc public static func parentLightGreyColor() -> UIColor {
        return UIColor(r: 210, g: 210, b: 210)
    }

    @objc public static func defaultTableViewBackgroundColor() -> UIColor {
        return UIColor(r: 240, g: 239, b: 238)
    }
}
