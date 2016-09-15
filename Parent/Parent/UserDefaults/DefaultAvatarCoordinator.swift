//
//  DefaultAvatarCoordinator.swift
//  Parent
//
//  Created by Brandon Pluim on 4/7/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
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