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

import UIKit

extension UIScreen {
    /// Reasonable approximation of points per inch for iOS devices.
    /// iPads: ~132, iPhones: ~163 (varies slightly by device model).
    public var pointsPerInch: CGFloat {
        UIDevice.current.userInterfaceIdiom.pointsPerInch
    }
}

extension UIUserInterfaceIdiom {
    /// Reasonable approximation of points per inch for iOS devices.
    /// iPads: ~132, iPhones: ~163 (varies slightly by device model).
    var pointsPerInch: CGFloat {
        switch self {
        case .pad: 132
        default: 163
        }
    }
}
