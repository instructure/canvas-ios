//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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
import SwiftUI

@available(iOSApplicationExtension 13.0, *)
extension Image {
    public typealias IconName = UIImage.IconName
    public typealias InstIconName = UIImage.InstIconName
    public typealias InstIconType = UIImage.InstIconType

    public static func icon(_ name: IconName) -> Image {
        Image(name.rawValue, bundle: .core)
    }

    public static func icon(_ name: InstIconName, _ type: InstIconType = .line) -> Image {
        let named = name.rawValue + type.rawValue
        return Image(named, bundle: .core)
    }
}
