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

extension DataTest {

  class CoursesTabPageTests_testCoursesTabPage_emptyList : DataProvider {
    override init() {
      super.init()

      var students = [CanvasUser]()
      students.append(CanvasUser(
        id:        7901559,
        domain:   "mobileqa.test.instructure.com",
        loginId:  "1487973743@2663ef37-5439-45a1-a0da-09687b398587.com",
        password: "79c35ac548c5a7b7",
        name:     "Liana Gutkowski"))

      parents.append(Parent(parentId: "f8a36cf4-56fe-4f62-a00b-4f8ba3ea08c8",
                            username:   "1487973742@1f7b22ae-b04d-4c12-86d1-b08da4bbfbd8.com",
                            password:   "6be83f56cce6a41d",
                            firstName:  "Katharina",
                            lastName:   "Ledner",
                            students:   [students[0]],
                            thresholds: [],
                            alerts:     []))
    }
  }
}
