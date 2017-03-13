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

  class CreateAccountPageTests_testCreateAccountPage_createAccountButtonDisabled_whenNoLastName : DataProvider {
    override init() {
      super.init()

      parents.append(Parent(parentId: "9d4ffb21-fbd0-49ff-924c-e8183a2823c3",
                            username:   "1487973745@15f09bde-8c4d-4089-ad7e-ff400e427e66.com",
                            password:   "7b3e441cc59b6918",
                            firstName:  "Alayna",
                            lastName:   "Jacobi",
                            students:   [],
                            thresholds: [],
                            alerts:     []))
    }
  }
}
