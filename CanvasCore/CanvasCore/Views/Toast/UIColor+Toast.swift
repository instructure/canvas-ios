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

extension UIColor {
    @objc public static var toastSuccess: UIColor {
        return UIColor(red: 0x00/255.0, green: 0xAD/255.0, blue: 0x18/255.0, alpha: 1.0)
    }
    @objc public static var toastInfo: UIColor {
        return UIColor(red: 0x00/255.0, green: 0x96/255.0, blue: 0xDB/255.0, alpha: 1.0)
    }
    @objc public static var toastFailure: UIColor {
        return UIColor(red: 0xAD/255.0, green: 0x39/255.0, blue: 0x3A/255.0, alpha: 1.0)
    }
}
