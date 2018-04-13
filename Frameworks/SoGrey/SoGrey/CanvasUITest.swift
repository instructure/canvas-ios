//
//  CanvasUITest.swift
//  SoGrey
//
//  Created by Layne Moseley on 4/12/18.
//  Copyright © 2018 Instructure. All rights reserved.
//

import Foundation
import XCTest

open class CanvasUITest : XCTestCase {}

public extension CanvasUITest {
    var dashboardPage: DashboardPage { return DashboardPage.sharedInstance }
    var profilePage: ProfilePage { return ProfilePage.sharedInstance }
    var editDashboardPage: EditDashboardPage { return EditDashboardPage.sharedInstance }
    var allCourseListPage: AllCoursesListPage { return AllCoursesListPage.sharedInstance }
}
