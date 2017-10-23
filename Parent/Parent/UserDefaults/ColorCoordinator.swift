//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
    
    

import Foundation




struct ColorScheme {
    let tintTopColor: UIColor
    let tintBottomColor: UIColor
    let highlightCellColor: UIColor

    static let blueColorScheme = ColorScheme(tintTopColor: UIColor(r: 0, g: 225, b: 255),
                                                 tintBottomColor: UIColor(r: 0, g: 30, b: 194),
                                                 highlightCellColor: UIColor(r: 0, g: 196, b: 255, a: 0.3))

    static let orangeColorScheme = ColorScheme(tintTopColor: UIColor(r: 225, g: 199, b: 0),
                                                   tintBottomColor: UIColor(r: 255, g: 0, b: 0),
                                                   highlightCellColor: UIColor(r: 255, g: 193, b: 0, a: 0.3))

    static let purpleColorScheme = ColorScheme(tintTopColor: UIColor(r: 213, g: 0, b: 119),
                                                   tintBottomColor: UIColor(r: 53, g: 20, b: 211),
                                                   highlightCellColor: UIColor(r: 185, g: 37, b: 255, a: 0.3))

    static let greenColorScheme = ColorScheme(tintTopColor: UIColor(r: 150, g: 235, b: 0),
                                                  tintBottomColor: UIColor(r: 3, g: 190, b: 119),
                                                  highlightCellColor: UIColor(r: 51, g: 241, b: 42, a: 0.3))


    
    static let colorSchemes: [ColorScheme] = {
        var colorSchemes: [ColorScheme] = []

        colorSchemes.append(ColorScheme.orangeColorScheme)
        colorSchemes.append(ColorScheme.blueColorScheme)
        colorSchemes.append(ColorScheme.purpleColorScheme)
        colorSchemes.append(ColorScheme.greenColorScheme)
        
        return colorSchemes
    }()

    func inverse() -> ColorScheme {
        return ColorScheme(tintTopColor: tintBottomColor, tintBottomColor: tintTopColor, highlightCellColor: highlightCellColor)
    }
}

class ColorCoordinator {
    static let CurrentIndexKey = "current__color_index"
    static let ColorSchemeDictionaryKey = "color_scheme_dictionary"

    static func colorSchemeForParent() -> ColorScheme {
        return ColorScheme.blueColorScheme
    }

    static func colorSchemeForStudent(_ student: Student) -> ColorScheme {
        return colorSchemeForKey(student.id)
    }

    static func colorSchemeForStudentID(_ studentID: String) -> ColorScheme {
        return colorSchemeForKey(studentID)
    }

    static func colorSchemeForKey(_ key: String) -> ColorScheme {
        guard let colorSchemeIndexDictionary = UserDefaults.standard.object(forKey: ColorSchemeDictionaryKey) as? [String : Int] else {
            var colorSchemeIndexDictionary = [String : Int]()
            let nextIndex = nextColorSchemeIndex()
            colorSchemeIndexDictionary[key] = nextIndex
            UserDefaults.standard.set(colorSchemeIndexDictionary, forKey: ColorSchemeDictionaryKey)
            return ColorScheme.colorSchemes[nextIndex]
        }

        var mutableIndexDictionary = colorSchemeIndexDictionary
        guard let colorSchemeIndex = colorSchemeIndexDictionary[key] else {
            let nextIndex = nextColorSchemeIndex()
            mutableIndexDictionary[key] = nextIndex
            UserDefaults.standard.set(mutableIndexDictionary, forKey: ColorSchemeDictionaryKey)
            return ColorScheme.colorSchemes[nextIndex]
        }

        return ColorScheme.colorSchemes[colorSchemeIndex]
    }

    static func nextColorSchemeIndex() -> Int {
        let defaults = UserDefaults.standard

        let currentIndex = defaults.integer(forKey: CurrentIndexKey)
        var nextIndex = currentIndex + 1
        if nextIndex >= ColorScheme.colorSchemes.count {
            nextIndex = 0
        }

        defaults.set(nextIndex, forKey: CurrentIndexKey)
        defaults.synchronize()

        return nextIndex
    }
    
}
