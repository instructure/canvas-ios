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

  class CreateAccountPageTests_testCreateAccountPage_createAccountButtonDisabled_whenNoPassword : DataProvider {
    override init() {
      super.init()

      parents.append(Parent(parentId: "3bcc7e87-86e7-419d-92a8-9200016d91fd",
                            username:   "1487973746@1890780e-4a3c-47b8-bffa-5dd0abf04b95.com",
                            password:   "65a614e0c28258a1",
                            firstName:  "Reina",
                            lastName:   "Gibson",
                            students:   [],
                            thresholds: [],
                            alerts:     []))
    }
  }
}
