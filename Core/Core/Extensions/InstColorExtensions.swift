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

public extension UIColor {
    static let ash = UIColor(named: "ash", in: .core, compatibleWith: nil)!
    static let backgroundAlert = UIColor(named: "backgroundAlert", in: .core, compatibleWith: nil)!
    static let backgroundDanger = UIColor(named: "backgroundDanger", in: .core, compatibleWith: nil)!
    static let backgroundDark = UIColor(named: "backgroundDark", in: .core, compatibleWith: nil)!
    static let backgroundDarkest = UIColor(named: "backgroundDarkest", in: .core, compatibleWith: nil)!
    static let backgroundGrouped = UIColor(named: "backgroundGrouped", in: .core, compatibleWith: nil)!
    static let backgroundGroupedCell = UIColor(named: "backgroundGroupedCell", in: .core, compatibleWith: nil)!
    static let backgroundInfo = UIColor(named: "backgroundInfo", in: .core, compatibleWith: nil)!
    static let backgroundLight = UIColor(named: "backgroundLight", in: .core, compatibleWith: nil)!
    static let backgroundLightest = UIColor(named: "backgroundLightest", in: .core, compatibleWith: nil)!
    static let backgroundMedium = UIColor(named: "backgroundMedium", in: .core, compatibleWith: nil)!
    static let backgroundSuccess = UIColor(named: "backgroundSuccess", in: .core, compatibleWith: nil)!
    static let backgroundWarning = UIColor(named: "backgroundWarning", in: .core, compatibleWith: nil)!
    static let barney = UIColor(named: "barney", in: .core, compatibleWith: nil)!
    static let borderAlert = UIColor(named: "borderAlert", in: .core, compatibleWith: nil)!
    static let borderDanger = UIColor(named: "borderDanger", in: .core, compatibleWith: nil)!
    static let borderDark = UIColor(named: "borderDark", in: .core, compatibleWith: nil)!
    static let borderDarkest = UIColor(named: "borderDarkest", in: .core, compatibleWith: nil)!
    static let borderInfo = UIColor(named: "borderInfo", in: .core, compatibleWith: nil)!
    static let borderLight = UIColor(named: "borderLight", in: .core, compatibleWith: nil)!
    static let borderLightest = UIColor(named: "borderLightest", in: .core, compatibleWith: nil)!
    static let borderMedium = UIColor(named: "borderMedium", in: .core, compatibleWith: nil)!
    static let borderSuccess = UIColor(named: "borderSuccess", in: .core, compatibleWith: nil)!
    static let borderWarning = UIColor(named: "borderWarning", in: .core, compatibleWith: nil)!
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
    static let backgroundAlert = Color("backgroundAlert", bundle: .core)
    static let backgroundDanger = Color("backgroundDanger", bundle: .core)
    static let backgroundDark = Color("backgroundDark", bundle: .core)
    static let backgroundDarkest = Color("backgroundDarkest", bundle: .core)
    static let backgroundGrouped = Color("backgroundGrouped", bundle: .core)
    static let backgroundGroupedCell = Color("backgroundGroupedCell", bundle: .core)
    static let backgroundInfo = Color("backgroundInfo", bundle: .core)
    static let backgroundLight = Color("backgroundLight", bundle: .core)
    static let backgroundLightest = Color("backgroundLightest", bundle: .core)
    static let backgroundMedium = Color("backgroundMedium", bundle: .core)
    static let backgroundSuccess = Color("backgroundSuccess", bundle: .core)
    static let backgroundWarning = Color("backgroundWarning", bundle: .core)
    static let barney = Color("barney", bundle: .core)
    static let borderAlert = Color("borderAlert", bundle: .core)
    static let borderDanger = Color("borderDanger", bundle: .core)
    static let borderDark = Color("borderDark", bundle: .core)
    static let borderDarkest = Color("borderDarkest", bundle: .core)
    static let borderInfo = Color("borderInfo", bundle: .core)
    static let borderLight = Color("borderLight", bundle: .core)
    static let borderLightest = Color("borderLightest", bundle: .core)
    static let borderMedium = Color("borderMedium", bundle: .core)
    static let borderSuccess = Color("borderSuccess", bundle: .core)
    static let borderWarning = Color("borderWarning", bundle: .core)
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
