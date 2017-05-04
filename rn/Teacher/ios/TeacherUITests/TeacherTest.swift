//
// Copyright (C) 2017-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation
import XCTest
import CanvasKeymaster

@testable import Teacher

class TeacherTest: XCTestCase {

  override func setUp() {
    super.setUp()
    CanvasKeymaster.the().resetKeymasterForTesting()
    domainPickerPage.assertPageObjects()
  }

  @discardableResult
  func logIn<T>(_ testClass:T, _ testMethod:String = #function, _ file: StaticString = #file, _ line: UInt = #line) -> CanvasUser {
    let teacher = Data.getNextTeacher(testClass, testMethod)
    domainPickerPage.openDomain(teacher.domain)
    canvasLoginPage.logIn(teacher: teacher)
    coursesListPage.assertPageObjects()
    return teacher
  }

  /*

   This logIn method is useful for running a test in a loop.

   func testSomething {
     let course = Data.getNextCourse(self)
     let teacher = Data.getNextTeacher(self)

     for _ in 1...1000 {
       setUp()
       logIn(teacher)
       // test code
       tearDown()
     }
   }
  */
  @discardableResult
  func logIn(_ teacher:CanvasUser, _ file: StaticString = #file, _ line: UInt = #line) -> CanvasUser {
    domainPickerPage.openDomain(teacher.domain)
    canvasLoginPage.logIn(teacher: teacher)
    return teacher
  }
}
