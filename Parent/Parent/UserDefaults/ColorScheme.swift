//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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
import Core

enum ColorScheme: String, CaseIterable {
    case observeeGreen, observeeBlue, observeePurple, observeePink, observeeRed, observeeOrange

    private static var lastScheme: ColorScheme?

    static var observer: ColorScheme {
        if let id = currentStudentID {
            return observee(id)
        } else if let id = AppEnvironment.shared.userDefaults?.parentCurrentStudentID {
            return observee(id)
        } else {
            return lastScheme ?? ColorScheme.observeeBlue
        }
    }

    var color: UIColor {
        UIColor(named: rawValue)!
    }

    private static let CurrentIndexKey = "current__color_index"
    private static var currentIndex: Int {
        get { UserDefaults.standard.integer(forKey: CurrentIndexKey) }
        set { UserDefaults.standard.set(newValue, forKey: CurrentIndexKey) }
    }

    private static let DictionaryKey = "color_scheme_dictionary"
    private static var dictionary: [String: Int]? {
        get { AppEnvironment.shared.userDefaults?.parentColorScheme }
        set { AppEnvironment.shared.userDefaults?.parentColorScheme = newValue }
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: CurrentIndexKey)
        AppEnvironment.shared.userDefaults?.parentColorScheme = nil
    }

    static func observee(_ studentID: String) -> ColorScheme {
        if let scheme = dictionary?[studentID].flatMap({ allCases[$0 % allCases.count] }) {
            lastScheme = scheme
            return scheme
        }
        var mapping = dictionary ?? [:]
        currentIndex = (currentIndex + 1) % allCases.count
        mapping[studentID] = currentIndex
        dictionary = mapping
        lastScheme = allCases[currentIndex]
        return allCases[currentIndex]
    }
}
