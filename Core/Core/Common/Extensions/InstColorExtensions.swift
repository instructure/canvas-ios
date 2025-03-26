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
    
    static let edxColor: UIColor = UIColor(red: 0.00, green: 0.15, blue: 0.17, alpha: 1.00)
    static let edxAcceptColor: UIColor =  UIColor(red: 0.88, green: 0.87, blue: 0.83, alpha: 1.00)
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

// MARK: - iOS Specific Colors

public extension UIColor {
    static let disabledGray = UIColor(resource: .disabledGray)
}

public extension Color {
    static let disabledGray = Color(uiColor: .disabledGray)
}
