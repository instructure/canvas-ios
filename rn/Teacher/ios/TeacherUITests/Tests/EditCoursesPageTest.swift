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

class EditCoursesPageTest: TeacherTest {
    var courses: [Soseedy_Course]!

    func testEditCoursesPage_displaysPageObjects() {
        getToEditCoursesPage()
        editCoursesListPage.assertPageObjects()
        editCoursesListPage.dismissToFavoriteCoursesPage()
    }

    func testEditCoursesPage_displaysCourseList() {
        getToEditCoursesPage(numCourses: 2, numFavorites: 1)
        editCoursesListPage.assertHasCourses(courses)
        editCoursesListPage.dismissToFavoriteCoursesPage()
    }

    func getToEditCoursesPage(numCourses: Int = 1, numFavorites: Int = 0) {
        courses = []
        for _ in 0..<numCourses {
            courses.append(createCourse())
        }
        let teacher = createTeacher(inAll: courses)
        for i in 0..<numFavorites {
            favorite(courses[i], as: teacher)
        }
        logIn2(teacher)
        coursesListPage.openCourseFavoritesEditPage(false)
    }

}
