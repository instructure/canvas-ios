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
import Core

public class WindowTraits: NSObject {
    @objc public static func current() -> [String: String] {
        guard let traitCollection = AppEnvironment.shared.window?.traitCollection else { return [:] }
        return [
            "style": traitCollection.isDarkInterface ? "dark" : "light",
            "contrast": UIAccessibility.isDarkerSystemColorsEnabled ? "high" : "normal",
            "horizontal": string(traitCollection.horizontalSizeClass),
            "vertical": string(traitCollection.verticalSizeClass),
        ]
    }

    static func string(_ size: UIUserInterfaceSizeClass) -> String {
        switch(size) {
        case .compact: return "compact"
        case .regular: return "regular"
        case .unspecified: fallthrough
        @unknown default: return "unspecified"
        }
    }
}
