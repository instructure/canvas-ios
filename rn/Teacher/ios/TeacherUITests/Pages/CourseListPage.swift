//
//  CourseBrowserPage.swift
//  Teacher
//
//  Created by Taylor Wilson on 3/21/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

import SoGrey
import EarlGrey

class CourseListPage {

  // MARK: Singleton

  static let sharedInstance = CourseListPage()
  private init() {}

  let seeAllCoursesButton = e.selectBy(id: "course-list.see-all-btn")

  // Mark: - Assertions

  func assertCourseExists(_ course: Course, _ file: StaticString = #file, _ line: UInt = #line) {
    grey_invokedFromFile(file, line)

    e.selectBy(id: course.courseCode).assertExists()
  }

  // Mark: - UI Actions

  func openAllCoursesPage(_ file: StaticString = #file, _ line: UInt = #line) {
    grey_invokedFromFile(file, line)

    seeAllCoursesButton.tap()
  }
}
