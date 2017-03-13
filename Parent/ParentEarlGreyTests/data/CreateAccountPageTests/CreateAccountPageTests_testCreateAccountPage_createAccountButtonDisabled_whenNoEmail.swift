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

  class CreateAccountPageTests_testCreateAccountPage_createAccountButtonDisabled_whenNoEmail : DataProvider {
    override init() {
      super.init()

      parents.append(Parent(parentId: "e7c7c1f3-1f4b-44de-a56b-e812ae066c96",
                            username:   "1487973745@92da4e3e-650b-4de9-bfa4-69238cdc4f49.com",
                            password:   "e3d902268f371f15",
                            firstName:  "May",
                            lastName:   "Jacobs",
                            students:   [],
                            thresholds: [],
                            alerts:     []))
    }
  }
}
