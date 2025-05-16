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
    static let textDanger = Color(uiColor: .textDanger)
    static let textDark = Color(uiColor: .textDark)
    static let textDarkest = Color(uiColor: .textDarkest)
    static let textInfo = Color(uiColor: .textInfo)
    static let textLight = Color(uiColor: .textLight)
    static let textLightest = Color(uiColor: .textLightest)
    static let textLink = Color(uiColor: .textLink)
    static let textMasquerade = Color(uiColor: .textMasquerade)
    static let textPlaceholder = Color(uiColor: .textPlaceholder)
    static let textSuccess = Color(uiColor: .textSuccess)
    static let textWarning = Color(uiColor: .textWarning)
}

public extension ShapeStyle where Self == Color {
    static var textDanger: Color { Color(uiColor: .textDanger) }
    static var textDark: Color { Color(uiColor: .textDark) }
    static var textDarkest: Color { Color(uiColor: .textDarkest) }
    static var textInfo: Color { Color(uiColor: .textInfo) }
    static var textLight: Color { Color(uiColor: .textLight) }
    static var textLightest: Color { Color(uiColor: .textLightest) }
    static var textLink: Color { Color(uiColor: .textLink) }
    static var textMasquerade: Color { Color(uiColor: .textMasquerade) }
    static var textPlaceholder: Color { Color(uiColor: .textPlaceholder) }
    static var textSuccess: Color { Color(uiColor: .textSuccess) }
    static var textWarning: Color { Color(uiColor: .textWarning) }
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
    static let backgroundDanger = Color(uiColor: .backgroundDanger)
    static let backgroundDark = Color(uiColor: .backgroundDark)
    static let backgroundDarkest = Color(uiColor: .backgroundDarkest)
    static let backgroundGrouped = Color(uiColor: .backgroundGrouped)
    static let backgroundGroupedCell = Color(uiColor: .backgroundGroupedCell)
    static let backgroundInfo = Color(uiColor: .backgroundInfo)
    static let backgroundLight = Color(uiColor: .backgroundLight)
    static let backgroundLightest = Color(uiColor: .backgroundLightest)
    static let backgroundLightestElevated = Color(uiColor: .backgroundLightestElevated)
    static let backgroundMasquerade = Color(uiColor: .backgroundMasquerade)
    static let backgroundMedium = Color(uiColor: .backgroundMedium)
    static let backgroundSuccess = Color(uiColor: .backgroundSuccess)
    static let backgroundWarning = Color(uiColor: .backgroundWarning)
}

public extension ShapeStyle where Self == Color {
    static var backgroundDanger: Color { Color(uiColor: .backgroundDanger) }
    static var backgroundDark: Color { Color(uiColor: .backgroundDark) }
    static var backgroundDarkest: Color { Color(uiColor: .backgroundDarkest) }
    static var backgroundGrouped: Color { Color(uiColor: .backgroundGrouped) }
    static var backgroundGroupedCell: Color { Color(uiColor: .backgroundGroupedCell) }
    static var backgroundInfo: Color { Color(uiColor: .backgroundInfo) }
    static var backgroundLight: Color { Color(uiColor: .backgroundLight) }
    static var backgroundLightest: Color { Color(uiColor: .backgroundLightest) }
    static var backgroundLightestElevated: Color { Color(uiColor: .backgroundLightestElevated) }
    static var backgroundMasquerade: Color { Color(uiColor: .backgroundMasquerade) }
    static var backgroundMedium: Color { Color(uiColor: .backgroundMedium) }
    static var backgroundSuccess: Color { Color(uiColor: .backgroundSuccess) }
    static var backgroundWarning: Color { Color(uiColor: .backgroundWarning) }
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
    static let borderDanger = Color(uiColor: .borderDanger)
    static let borderDark = Color(uiColor: .borderDark)
    static let borderDarkest = Color(uiColor: .borderDarkest)
    static let borderDebug = Color(uiColor: .borderDebug)
    static let borderInfo = Color(uiColor: .borderInfo)
    static let borderLight = Color(uiColor: .borderLight)
    static let borderLightest = Color(uiColor: .borderLightest)
    static let borderMasquerade = Color(uiColor: .borderMasquerade)
    static let borderMedium = Color(uiColor: .borderMedium)
    static let borderSuccess = Color(uiColor: .borderSuccess)
    static let borderWarning = Color(uiColor: .borderWarning)
}

public extension ShapeStyle where Self == Color {
    static var borderDanger: Color { Color(uiColor: .borderDanger) }
    static var borderDark: Color { Color(uiColor: .borderDark) }
    static var borderDarkest: Color { Color(uiColor: .borderDarkest) }
    static var borderDebug: Color { Color(uiColor: .borderDebug) }
    static var borderInfo: Color { Color(uiColor: .borderInfo) }
    static var borderLight: Color { Color(uiColor: .borderLight) }
    static var borderLightest: Color { Color(uiColor: .borderLightest) }
    static var borderMasquerade: Color { Color(uiColor: .borderMasquerade) }
    static var borderMedium: Color { Color(uiColor: .borderMedium) }
    static var borderSuccess: Color { Color(uiColor: .borderSuccess) }
    static var borderWarning: Color { Color(uiColor: .borderWarning) }
}

// MARK: - Course Colors

public extension UIColor {
    static let course1 = UIColor(resource: .course1)
    static let course2 = UIColor(resource: .course2)
    static let course3 = UIColor(resource: .course3)
    static let course4 = UIColor(resource: .course4)
    static let course5 = UIColor(resource: .course5)
    static let course6 = UIColor(resource: .course6)
    static let course7 = UIColor(resource: .course7)
    static let course8 = UIColor(resource: .course8)
    static let course9 = UIColor(resource: .course9)
    static let course10 = UIColor(resource: .course10)
    static let course11 = UIColor(resource: .course11)
    static let course12 = UIColor(resource: .course12)
}

public extension Color {
    static let course1 = Color(uiColor: .course1)
    static let course2 = Color(uiColor: .course2)
    static let course3 = Color(uiColor: .course3)
    static let course4 = Color(uiColor: .course4)
    static let course5 = Color(uiColor: .course5)
    static let course6 = Color(uiColor: .course6)
    static let course7 = Color(uiColor: .course7)
    static let course8 = Color(uiColor: .course8)
    static let course9 = Color(uiColor: .course9)
    static let course10 = Color(uiColor: .course10)
    static let course11 = Color(uiColor: .course11)
    static let course12 = Color(uiColor: .course12)
}

public extension ShapeStyle where Self == Color {
    static var course1: Color { Color(uiColor: .course1) }
    static var course2: Color { Color(uiColor: .course2) }
    static var course3: Color { Color(uiColor: .course3) }
    static var course4: Color { Color(uiColor: .course4) }
    static var course5: Color { Color(uiColor: .course5) }
    static var course6: Color { Color(uiColor: .course6) }
    static var course7: Color { Color(uiColor: .course7) }
    static var course8: Color { Color(uiColor: .course8) }
    static var course9: Color { Color(uiColor: .course9) }
    static var course10: Color { Color(uiColor: .course10) }
    static var course11: Color { Color(uiColor: .course11) }
    static var course12: Color { Color(uiColor: .course12) }
}

// MARK: - iOS Specific Colors

public extension UIColor {
    static let disabledGray = UIColor(resource: .disabledGray)
}

public extension Color {
    static let disabledGray = Color(uiColor: .disabledGray)
}

public extension ShapeStyle where Self == Color {
    static var disabledGray: Color { Color(uiColor: .disabledGray) }
}
