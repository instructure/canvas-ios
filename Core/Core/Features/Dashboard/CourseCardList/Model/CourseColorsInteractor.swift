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
    // Used elsewhere without the live interactor's logic
    public static let colors: [CourseColorData] = [
        CourseColorData(persistentId: "plum", color: .course1, name: String(localized: "Plum", bundle: .core, comment: "This is a name of a color.")),
        CourseColorData(persistentId: "fuchsia", color: .course2, name: String(localized: "Fuchsia", bundle: .core, comment: "This is a name of a color.")),
        CourseColorData(persistentId: "violet", color: .course3, name: String(localized: "Violet", bundle: .core, comment: "This is a name of a color.")),
        CourseColorData(persistentId: "ocean", color: .course4, name: String(localized: "Ocean", bundle: .core, comment: "This is a name of a color.")),
        CourseColorData(persistentId: "sky", color: .course5, name: String(localized: "Sky", bundle: .core, comment: "This is a name of a color.")),
        CourseColorData(persistentId: "sea", color: .course6, name: String(localized: "Sea", bundle: .core, comment: "This is a name of a color.")),
        CourseColorData(persistentId: "aurora", color: .course7, name: String(localized: "Aurora", bundle: .core, comment: "This is a name of a color.")),
        CourseColorData(persistentId: "forest", color: .course8, name: String(localized: "Forest", bundle: .core, comment: "This is a name of a color.")),
        CourseColorData(persistentId: "honey", color: .course9, name: String(localized: "Honey", bundle: .core, comment: "This is a name of a color.")),
        CourseColorData(persistentId: "copper", color: .course10, name: String(localized: "Copper", bundle: .core, comment: "This is a name of a color.")),
        CourseColorData(persistentId: "rose", color: .course11, name: String(localized: "Rose", bundle: .core, comment: "This is a name of a color.")),
        CourseColorData(persistentId: "stone", color: .course12, name: String(localized: "Stone", bundle: .core, comment: "This is a name of a color."))
    ]

    public var colors: [CourseColorData] {
        Self.colors
    }

    public init() {
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
