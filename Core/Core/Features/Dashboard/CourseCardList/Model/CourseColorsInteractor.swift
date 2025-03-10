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
import UIKit

public protocol CourseColorsInteractor {
    /// These are the pre-defined course colors the user can choose from. The values are the color names for accessibility.
    var colors: KeyValuePairs<UIColor, String> { get }

    /// - parameters:
    ///   - colorHex: The hex color of the color in light theme.
    func courseColorFromAPIColor(_ colorHex: String) -> UIColor
}

public class CourseColorsInteractorLive: CourseColorsInteractor {
    public let colors: KeyValuePairs<UIColor, String> = [
        .course1: String(localized: "Plum", bundle: .core, comment: "This is a name of a color."),
        .course2: String(localized: "Fuchsia", bundle: .core, comment: "This is a name of a color."),
        .course3: String(localized: "Violet", bundle: .core, comment: "This is a name of a color."),
        .course4: String(localized: "Ocean", bundle: .core, comment: "This is a name of a color."),
        .course5: String(localized: "Sky", bundle: .core, comment: "This is a name of a color."),
        .course6: String(localized: "Sea", bundle: .core, comment: "This is a name of a color."),
        .course7: String(localized: "Aurora", bundle: .core, comment: "This is a name of a color."),
        .course8: String(localized: "Forest", bundle: .core, comment: "This is a name of a color."),
        .course9: String(localized: "Honey", bundle: .core, comment: "This is a name of a color."),
        .course10: String(localized: "Copper", bundle: .core, comment: "This is a name of a color."),
        .course11: String(localized: "Rose", bundle: .core, comment: "This is a name of a color."),
        .course12: String(localized: "Stone", bundle: .core, comment: "This is a name of a color.")
    ]

    public init() {
    }

    public func courseColorFromAPIColor(_ colorHex: String) -> UIColor {
        let predefinedColor = colors.first { (color, _) in
            color.variantForLightMode.hexString == colorHex
        }?.key

        if let predefinedColor {
            return predefinedColor
        }

        guard let apiColor = UIColor(hexString: colorHex) else {
            return .textDarkest
        }

        let lightVariant: UIColor = {
            apiColor.darkenToEnsureContrast(against: .backgroundLightest.variantForLightMode)
        }()
        let darkVariant: UIColor = {
            apiColor.ensureContrast(against: .backgroundLightest.variantForDarkMode)
        }()

        return UIColor.getColor(dark: darkVariant, light: lightVariant)
    }

    public func courseColorFromAPIColor(_ color: UIColor) -> UIColor {
        courseColorFromAPIColor(color.hexString)
    }
}
