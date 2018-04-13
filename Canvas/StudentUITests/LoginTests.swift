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

class LoginTests: StudentUITestBase {
    
    func testLoginPageExists() {
        e.selectBy(id: "findMySchoolButton").assertExists()
    }
    
    func testLoginSearchPage() {
        e.selectBy(id: "findMySchoolButton").assertExists()
        e.selectBy(id: "findMySchoolButton").tap()
        e.selectBy(id: "searchSchoolTextField").assertExists()
    }
}
