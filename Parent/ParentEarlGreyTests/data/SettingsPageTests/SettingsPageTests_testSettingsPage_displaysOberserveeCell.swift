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

  class SettingsPageTests_testSettingsPage_displaysOberserveeCell : DataProvider {
    override init() {
      super.init()

      var students = [CanvasUser]()
      students.append(CanvasUser(
        id:        7901563,
        domain:   "mobileqa.test.instructure.com",
        loginId:  "1487973756@681bb209-7919-4e13-8522-9016c23dc129.com",
        password: "1f797122e632f525",
        name:     "Cristina Graham"))

      parents.append(Parent(parentId: "a31dedca-31b7-4cff-8a72-805b0aabc8d1",
                            username:   "1487973756@4dd1364a-976e-4f28-a435-52498cfeeaf9.com",
                            password:   "5022d52a6cc43626",
                            firstName:  "Adelbert",
                            lastName:   "Hand",
                            students:   [students[0]],
                            thresholds: [],
                            alerts:     []))
    }
  }
}
