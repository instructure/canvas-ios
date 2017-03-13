//
// Copyright (C) 2016-present Instructure, Inc.
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

import UIKit
import SoPretty


extension Brand {
    public static let teacherKit = Brand(
        tintColor:UIColor(hue: 350/360.0, saturation: 1.0, brightness: 0.76, alpha: 0),
        secondaryTintColor: UIColor(hue: 205/360.0, saturation: 0.92, brightness: 0.82, alpha: 1.0),
        navBarTintColor: UIColor(hue: 229/360.0, saturation: 1.0, brightness: 0.24, alpha: 1.0),
        navForegroundColor: .white,
        tabBarTintColor: .white,
        tabsForegroundColor: UIColor(hue: 229/360.0, saturation: 1.0, brightness: 0.24, alpha: 1.0),
        logo: UIImage(named: "logo", in: .teacherKit, compatibleWith: nil)!
    )
}
