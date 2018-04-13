//
//  CourseListTests.swift
//  StudentUITests
//
//  Created by Layne Moseley on 4/12/18.
//  Copyright © 2018 Instructure. All rights reserved.
//

import XCTest
import SoGrey
import EarlGrey
import CanvasCore
import SoSeedySwift
@testable import CanvasKeymaster

class DashboardTests: StudentUITest {
    
    func testCourseList() {
        dashboardPage.assertCourseExists(self.courses.first!)
        dashboardPage.assertCourseDoesNotExist(self.courses.last!)
    }
    
    func testCourseFavoriteList() {
        dashboardPage.openCourseFavoritesEditPage(false)
        editDashboardPage.assertPageObjects()
        editDashboardPage.assertHasCourses(self.courses)
    }
    
    func testAllCoursesList() {
        dashboardPage.openAllCoursesPage()
        allCourseListPage.assertPageObjects()
    }
    
    func testProfileOpens() {
        dashboardPage.openProfile()
        profilePage.assertPageObjects()
    }
}
