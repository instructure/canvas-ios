//
//  CourseBrowserPage.swift
//  Teacher
//
//  Created by Taylor Wilson on 3/21/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

import SoGrey
import EarlGrey

class CourseListPage: PageObject {
  private static var seeAllCoursesButton: GREYElementInteraction {
    return EarlGrey.select(elementWithMatcher: grey_accessibilityID("course-list.see-all-btn"))
  }

  static func uniquePageElement() -> GREYElementInteraction {
    return seeAllCoursesButton
  }

  static func assertPageObjects(_ file: StaticString = #file, _ line: UInt = #line) {
    // todo
  }

  static func assertEmptyFavorites() {
    // todo
  }

  static func assertCourseExists(_ course: Course) {
    waitForPageToLoad()
    let element = EarlGrey.select(elementWithMatcher: grey_accessibilityID(course.courseCode))
    waitForElementToLoad(element: element)
  }
  
  static func openAllCoursesPage() {
    seeAllCoursesButton.perform(grey_tap())
  }
}
