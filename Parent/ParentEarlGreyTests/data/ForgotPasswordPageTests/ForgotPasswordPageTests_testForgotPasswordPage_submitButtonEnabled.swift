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

  class ForgotPasswordPageTests_testForgotPasswordPage_submitButtonEnabled : DataProvider {
    override init() {
      super.init()

      parents.append(Parent(parentId: "05c55d03-7097-4841-bd6b-025eec6f3dc5",
                            username:   "1487973749@32da05fd-357d-4bbe-a266-8d1fd27ed633.com",
                            password:   "b3f080c615ffd06c",
                            firstName:  "Danny",
                            lastName:   "Schmidt",
                            students:   [],
                            thresholds: [],
                            alerts:     []))
    }
  }
}
