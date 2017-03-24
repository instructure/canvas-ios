//
//  CourseBrowserPage.swift
//  Teacher
//
//  Created by Taylor Wilson on 3/21/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

import SoGrey
import EarlGrey

class CourseBrowserPage: PageObject {
  private static var editCourseFavoritesButton: GREYElementInteraction {
    return EarlGrey.select(elementWithMatcher: grey_accessibilityID("Edit"))
  }

  static func uniquePageElement() -> GREYElementInteraction {
    // todo
    return editCourseFavoritesButton
  }

  static func assertPageObjects(_ file: StaticString = #file, _ line: UInt = #line) {
    // todo
  }

  static func assertEmptyFavorites() {
    EarlGrey.select(elementWithMatcher: grey_accessibilityLabel(""))
  }

  static func openAllCoursesPage() {
    editCourseFavoritesButton.perform(grey_tap())
  }
}
