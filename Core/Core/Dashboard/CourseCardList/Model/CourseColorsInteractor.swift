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

public protocol CourseColorsInteractor {
    var colors: KeyValuePairs<UIColor, String> { get }

    /// - parameters:
    ///   - colorHex: The hex color of the color in light theme.
    func courseColorFromAPIColor(_ colorHex: String) -> UIColor
}

public class CourseColorsInteractorLive: CourseColorsInteractor {
    public let colors: KeyValuePairs<UIColor, String> = [
        .course1: String(localized: "Plum", bundle: .core),
        .course2: String(localized: "Fuchsia", bundle: .core),
        .course3: String(localized: "Violet", bundle: .core),
        .course4: String(localized: "Ocean", bundle: .core),
        .course5: String(localized: "Sky", bundle: .core),
        .course6: String(localized: "Sea", bundle: .core),
        .course7: String(localized: "Aurora", bundle: .core),
        .course8: String(localized: "Forest", bundle: .core),
        .course9: String(localized: "Honey", bundle: .core),
        .course10: String(localized: "Copper", bundle: .core),
        .course11: String(localized: "Rose", bundle: .core),
        .course12: String(localized: "Stone", bundle: .core)
    ]

    public init() {
    }

    public func courseColorFromAPIColor(_ colorHex: String) -> UIColor {
        let predefinedColor = colors.first { (color, _) in
            color.lightVariant.hexString == colorHex
        }?.key

        if let predefinedColor {
            return predefinedColor
        }

        let apiColor = UIColor(hexString: colorHex) ?? .textDarkest

        let lightVariant: UIColor = {
            apiColor.darkenToEnsureContrast(against: .backgroundLightest.lightVariant)
        }()
        let darkVariant: UIColor = {
            apiColor.ensureContrast(against: .backgroundLightest.darkVariant)
        }()

        return UIColor.getColor(dark: darkVariant, light: lightVariant)
    }

    public func courseColorFromAPIColor(_ color: UIColor) -> UIColor {
        courseColorFromAPIColor(color.hexString)
    }
}
