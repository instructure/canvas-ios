
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
import TooLegit
import Airwolf

class DefaultAvatarCoordinator {
    static let CurrentAvatarIndexKey = "current_image_index"
    static let DefaultAvatarDictionaryKey = "default_avatar_dictionary"

    static let avatarImages: [UIImage] = {
        var avatarImages: [UIImage] = []

        avatarImages.append(UIImage(named: "avatar_1")!)
        avatarImages.append(UIImage(named: "avatar_2")!)
        avatarImages.append(UIImage(named: "avatar_3")!)

        return avatarImages
    }()

    static func defaultAvatarForStudent(student: Student) -> UIImage {
        return defaultAvatarForStudentID(student.id)
    }

    static func defaultAvatarForStudentID(studentID: String) -> UIImage {
        return defaultAvatarForKey(studentID)
    }

    static func defaultAvatarForKey(key: String) -> UIImage {
        guard let colorSchemeIndexDictionary = NSUserDefaults.standardUserDefaults().objectForKey(DefaultAvatarDictionaryKey) as? [String : Int] else {
            var colorSchemeIndexDictionary = [String : Int]()
            let nextIndex = nextAvatarIndex()
            colorSchemeIndexDictionary[key] = nextIndex
            NSUserDefaults.standardUserDefaults().setObject(colorSchemeIndexDictionary, forKey: DefaultAvatarDictionaryKey)
            return DefaultAvatarCoordinator.avatarImages[nextIndex]
        }

        var mutableIndexDictionary = colorSchemeIndexDictionary
        guard let colorSchemeIndex = colorSchemeIndexDictionary[key] else {
            let nextIndex = nextAvatarIndex()
            mutableIndexDictionary[key] = nextIndex
            NSUserDefaults.standardUserDefaults().setObject(mutableIndexDictionary, forKey: DefaultAvatarDictionaryKey)
            return DefaultAvatarCoordinator.avatarImages[nextIndex]
        }

        return DefaultAvatarCoordinator.avatarImages[colorSchemeIndex]
    }

    static func nextAvatarIndex() -> Int {
        let defaults = NSUserDefaults.standardUserDefaults()

        let currentIndex = defaults.integerForKey(CurrentAvatarIndexKey)
        var nextIndex = currentIndex + 1
        if nextIndex >= DefaultAvatarCoordinator.avatarImages.count {
            nextIndex = 0
        }

        defaults.setInteger(nextIndex, forKey: CurrentAvatarIndexKey)
        defaults.synchronize()
        
        return nextIndex
    }
    
}