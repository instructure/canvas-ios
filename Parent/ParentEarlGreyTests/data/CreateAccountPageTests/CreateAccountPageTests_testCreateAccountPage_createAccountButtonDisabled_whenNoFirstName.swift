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

  class CreateAccountPageTests_testCreateAccountPage_createAccountButtonDisabled_whenNoFirstName : DataProvider {
    override init() {
      super.init()

      parents.append(Parent(parentId: "9d5b2e87-8765-45c7-813d-5109049e21d2",
                            username:   "1487973745@64ea90e8-9036-401f-8b26-2ad9d256777b.com",
                            password:   "6c310f66759d7992",
                            firstName:  "Zita",
                            lastName:   "Blick",
                            students:   [],
                            thresholds: [],
                            alerts:     []))
    }
  }
}
