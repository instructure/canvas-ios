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

@testable import Teacher

class CourseListPageTest: TeacherTest {
  
  func testCourseListPage_displaysList() {
//    logIn(self)
//    let course = Data.getNextCourse(self)
//    coursesListPage.assertCourseExists(course)
    
    // This is a test for the new way of testing without actually needing to login
    let course = Data.getNextCourse(self)
    let teacher = Data.getNextTeacher(self)
    
    let user: [String: Any] = ["id": teacher.id, "name": teacher.name, "primary_email": teacher.loginId, "short_name": teacher.shortName, "avatar_url": teacher.avatarUrl]
    let loginInfo: [String: Any] = ["authToken": teacher.token, "baseURL": "https://\(teacher.domain)/", "user": user]
    
    for _ in 1...10 {
      NativeLoginManager.shared().injectLoginInformation(loginInfo)
      coursesListPage.assertCourseExists(course)
      NativeLoginManager.shared().injectLoginInformation(nil)
    }
  }

  func testCourseListEmptyPage_displaysEmptyState() {
    logIn(self)
  }
}
