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
    let mainColor: UIColor
    let secondaryColor: UIColor
    let highlightCellColor: UIColor
    
    static let highlightCellColor = UIColor(r: 245, g: 245, b: 245)

    static let blueColorScheme = ColorScheme(mainColor: UIColor(r: 0, g: 142, b: 226),
                                             secondaryColor: UIColor(r: 0, g: 127, b: 202),
                                             highlightCellColor: ColorScheme.highlightCellColor)
    
    static let orangeColorScheme = ColorScheme(mainColor: UIColor(r: 252, g: 94, b: 19),
                                               secondaryColor: UIColor(r: 237, g: 88, b: 17),
                                               highlightCellColor: ColorScheme.highlightCellColor)

    static let purpleColorScheme = ColorScheme(mainColor: UIColor(r: 84, g: 67, b: 193),
                                               secondaryColor: UIColor(r: 75, g: 60, b: 173),
                                               highlightCellColor: ColorScheme.highlightCellColor)

    static let greenColorScheme = ColorScheme(mainColor: UIColor(r: 0, g: 172, b: 24),
                                              secondaryColor: UIColor(r: 0, g: 154, b: 21),
                                              highlightCellColor: ColorScheme.highlightCellColor)

    static let pinkColorScheme = ColorScheme(mainColor: UIColor(r: 191, g: 50, b: 164),
                                             secondaryColor: UIColor(r: 171, g: 44, b: 147),
                                             highlightCellColor: ColorScheme.highlightCellColor)
    
    static let redColorScheme = ColorScheme(mainColor: UIColor(r: 236, g: 51, b: 73),
                                            secondaryColor: UIColor(r: 211, g: 45, b: 65),
                                            highlightCellColor: ColorScheme.highlightCellColor)
    
    static let colorSchemes: [ColorScheme] = {
        var colorSchemes: [ColorScheme] = []
        
        // Put the last color first because of how nextColorSchemeIndex() works
        // in getting the starting index from UserDefaults
        colorSchemes.append(ColorScheme.greenColorScheme)
        colorSchemes.append(ColorScheme.blueColorScheme)
        colorSchemes.append(ColorScheme.purpleColorScheme)
        colorSchemes.append(ColorScheme.pinkColorScheme)
        colorSchemes.append(ColorScheme.redColorScheme)
        colorSchemes.append(ColorScheme.orangeColorScheme)
        
        return colorSchemes
    }()
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

        if colorSchemeIndex >= ColorScheme.colorSchemes.count {
            return ColorScheme.colorSchemes[0]
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
    
    static func clearColorSchemeDictionary() {
        UserDefaults.standard.set(nil, forKey: ColorSchemeDictionaryKey)
        UserDefaults.standard.set(0, forKey: CurrentIndexKey)
    }
}
