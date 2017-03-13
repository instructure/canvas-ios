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

  class SettingsPageTests_testSettingsPage_displaysHelpMenu : DataProvider {
    override init() {
      super.init()

      var students = [CanvasUser]()
      students.append(CanvasUser(
        id:        7901562,
        domain:   "mobileqa.test.instructure.com",
        loginId:  "1487973754@40d4dafc-6c6c-4310-903b-a717a81389ac.com",
        password: "2771952c15aa7538",
        name:     "Meredith Runolfsson"))

      parents.append(Parent(parentId: "9cb66078-b9b8-4eba-aa16-032396f3a4f5",
                            username:   "1487973753@f7d55b5d-6c07-4b8e-b05b-a5752e3169f3.com",
                            password:   "4df2ac9f36083a27",
                            firstName:  "London",
                            lastName:   "Dickinson",
                            students:   [students[0]],
                            thresholds: [],
                            alerts:     []))
    }
  }
}
