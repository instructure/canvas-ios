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

  class CreateAccountPageTests_testCreateAccountPage_createAccountButtonDisabled_whenNoConfirmPassword : DataProvider {
    override init() {
      super.init()

      parents.append(Parent(parentId: "70767e9d-18ab-4f64-a5e9-7bcff5ea22f8",
                            username:   "1487973746@5bb29ccc-3051-4f51-a2ea-2ba41d98d49d.com",
                            password:   "0d03f433db36c6f8",
                            firstName:  "Stefanie",
                            lastName:   "Lindgren",
                            students:   [],
                            thresholds: [],
                            alerts:     []))
    }
  }
}
