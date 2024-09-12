//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

import SwiftUI
import UIKit

// MARK: - Text Colors

public extension UIColor {
    static let textDanger = UIColor(resource: .textDanger)
    static let textDark = UIColor(resource: .textDark)
    static let textDarkest = UIColor(resource: .textDarkest)
    static let textInfo = UIColor(resource: .textInfo)
    static let textLight = UIColor(resource: .textLight)
    static let textLightest = UIColor(resource: .textLightest)
    static let textLink = UIColor(resource: .textLink)
    static let textMasquerade = UIColor(resource: .textMasquerade)
    static let textPlaceholder = UIColor(resource: .textPlaceholder)
    static let textSuccess = UIColor(resource: .textSuccess)
    static let textWarning = UIColor(resource: .textWarning)
}

public extension Color {
    static let textDanger = Color(.textDanger)
    static let textDark = Color(.textDark)
    static let textDarkest = Color(.textDarkest)
    static let textInfo = Color(.textInfo)
    static let textLight = Color(.textLight)
    static let textLightest = Color(.textLightest)
    static let textLink = Color(.textLink)
    static let textMasquerade = Color(.textMasquerade)
    static let textPlaceholder = Color(.textPlaceholder)
    static let textSuccess = Color(.textSuccess)
    static let textWarning = Color(.textWarning)
}

// MARK: - Background Colors

public extension UIColor {
    static let backgroundDanger = UIColor(resource: .backgroundDanger)
    static let backgroundDark = UIColor(resource: .backgroundDark)
    static let backgroundDarkest = UIColor(resource: .backgroundDarkest)
    static let backgroundGrouped = UIColor(resource: .backgroundGrouped)
    static let backgroundGroupedCell = UIColor(resource: .backgroundGroupedCell)
    static let backgroundInfo = UIColor(resource: .backgroundInfo)
    static let backgroundLight = UIColor(resource: .backgroundLight)
    static let backgroundLightest = UIColor(resource: .backgroundLightest)
    static let backgroundLightestElevated = UIColor(resource: .backgroundLightestElevated)
    static let backgroundMasquerade = UIColor(resource: .backgroundMasquerade)
    static let backgroundMedium = UIColor(resource: .backgroundMedium)
    static let backgroundSuccess = UIColor(resource: .backgroundSuccess)
    static let backgroundWarning = UIColor(resource: .backgroundWarning)
}

public extension Color {
    static let backgroundDanger = Color(.backgroundDanger)
    static let backgroundDark = Color(.backgroundDark)
    static let backgroundDarkest = Color(.backgroundDarkest)
    static let backgroundGrouped = Color(.backgroundGrouped)
    static let backgroundGroupedCell = Color(.backgroundGroupedCell)
    static let backgroundInfo = Color(.backgroundInfo)
    static let backgroundLight = Color(.backgroundLight)
    static let backgroundLightest = Color(.backgroundLightest)
    static let backgroundLightestElevated = Color(.backgroundLightestElevated)
    static let backgroundMasquerade = Color(.backgroundMasquerade)
    static let backgroundMedium = Color(.backgroundMedium)
    static let backgroundSuccess = Color(.backgroundSuccess)
    static let backgroundWarning = Color(.backgroundWarning)
}

// MARK: - Border Colors

public extension UIColor {
    static let borderDanger = UIColor(resource: .borderDanger)
    static let borderDark = UIColor(resource: .borderDark)
    static let borderDarkest = UIColor(resource: .borderDarkest)
    static let borderDebug = UIColor(resource: .borderDebug)
    static let borderInfo = UIColor(resource: .borderInfo)
    static let borderLight = UIColor(resource: .borderLight)
    static let borderLightest = UIColor(resource: .borderLightest)
    static let borderMasquerade = UIColor(resource: .borderMasquerade)
    static let borderMedium = UIColor(resource: .borderMedium)
    static let borderSuccess = UIColor(resource: .borderSuccess)
    static let borderWarning = UIColor(resource: .borderWarning)
}

public extension Color {
    static let borderDanger = Color(.borderDanger)
    static let borderDark = Color(.borderDark)
    static let borderDarkest = Color(.borderDarkest)
    static let borderDebug = Color(.borderDebug)
    static let borderInfo = Color(.borderInfo)
    static let borderLight = Color(.borderLight)
    static let borderLightest = Color(.borderLightest)
    static let borderMasquerade = Color(.borderMasquerade)
    static let borderMedium = Color(.borderMedium)
    static let borderSuccess = Color(.borderSuccess)
    static let borderWarning = Color(.borderWarning)
}

public extension UIColor {
    static let ash = UIColor(named: "ash", in: .core, compatibleWith: nil)!
    static let barney = UIColor(named: "barney", in: .core, compatibleWith: nil)!
    static let crimson = UIColor(named: "crimson", in: .core, compatibleWith: nil)!
    static let disabledGray = UIColor(named: "disabledGray", in: .core, compatibleWith: nil)!
    static let electric = UIColor(named: "electric", in: .core, compatibleWith: nil)!
    static let fire = UIColor(named: "fire", in: .core, compatibleWith: nil)!
    static let licorice = UIColor(named: "licorice", in: .core, compatibleWith: nil)!
    static let oxford = UIColor(named: "oxford", in: .core, compatibleWith: nil)!
    static let placeholderGray = UIColor(named: "placeholderGray", in: .core, compatibleWith: nil)!
    static let porcelain = UIColor(named: "porcelain", in: .core, compatibleWith: nil)!
    static let shamrock = UIColor(named: "shamrock", in: .core, compatibleWith: nil)!
    static let tabBarBackground = UIColor(named: "tabBarBackground", in: .core, compatibleWith: nil)!
    static let tiara = UIColor(named: "tiara", in: .core, compatibleWith: nil)!
}

public extension Color {
    static let ash = Color("ash", bundle: .core)
    static let barney = Color("barney", bundle: .core)
    static let crimson = Color("crimson", bundle: .core)
    static let disabledGray = Color("disabledGray", bundle: .core)
    static let electric = Color("electric", bundle: .core)
    static let electricHighContrast = Color("electricHighContrast", bundle: .core)
    static let fire = Color("fire", bundle: .core)
    static let licorice = Color("licorice", bundle: .core)
    static let oxford = Color("oxford", bundle: .core)
    static let placeholderGray = Color("placeholderGray", bundle: .core)
    static let porcelain = Color("porcelain", bundle: .core)
    static let shamrock = Color("shamrock", bundle: .core)
    static let tabBarBackground = Color("tabBarBackground", bundle: .core)
    static let tiara = Color("tiara", bundle: .core)
}
