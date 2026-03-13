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

import UIKit

public protocol CourseColorsInteractor {
    /// These are the pre-defined course colors the user can choose from.
    var colors: [CourseColorData] { get }

    /// - parameters:
    ///   - colorHex: The hex color of the color in light theme.
    func courseColorFromAPIColor(_ colorHex: String) -> UIColor
}

public class CourseColorsInteractorLive: CourseColorsInteractor {
    public let colors: [CourseColorData]

    public init(colors: [CourseColorData] = CourseColorData.all) {
        self.colors = colors
    }

    public func courseColorFromAPIColor(_ colorHex: String) -> UIColor {
        let predefinedColor = colors.first {
            $0.color.variantForLightMode.hexString == colorHex
        }?.color

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
