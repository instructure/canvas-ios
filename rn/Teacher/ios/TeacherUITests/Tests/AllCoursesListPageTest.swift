//
// Copyright (C) 2016-present Instructure, Inc.
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

class AllCoursesListPageTest: TeacherTest {

    //TestRail ID = C3108901
    func testAllCoursesListPage_displaysPageObjects() {
        let client = Soseedy_SoSeedyService.init(address: "localhost:50051")
        let user:Soseedy_CanvasUser = try! client.createcanvasuser(Soseedy_CreateCanvasUserRequest())
        let course:Soseedy_Course = try! client.createcourse(Soseedy_CreateCourseRequest())

        var enrollRequest = Soseedy_EnrollUserRequest()
        enrollRequest.courseID = course.id
        enrollRequest.userID = user.id
        enrollRequest.enrollmentType = "TeacherEnrollment"
        let _ = try! client.enrolluserincourse(enrollRequest)

        logIn2(user)

        coursesListPage.openAllCoursesPage()
        allCoursesListPage.assertPageObjects()
    }

//    //TestRail ID = C3108901
//    func testAllCoursesListPage_displaysCourseList() {
//        logIn(self)
//        let courses = Data.getAllCourses(self)
//        coursesListPage.openAllCoursesPage()
//        allCoursesListPage.assertHasCourses(courses)
//    }
}
