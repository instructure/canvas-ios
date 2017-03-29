//
//  CourseListPageTest.swift
//  Teacher
//
//  Created by Layne Moseley on 3/29/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

import Foundation

class CourseListPageTest: LogoutBeforeEach {
  
  func testCourseListPage_displaysList() {
    let teacher = Data.getNextTeacher(self)
    domainPickerPage.openDomain(teacher.domain)
    canvasLoginPage.logIn(teacher: teacher)
    let course = Data.getNextCourse(self)
    courseBrowserPage.assertCourseExists(course)
  }
}
