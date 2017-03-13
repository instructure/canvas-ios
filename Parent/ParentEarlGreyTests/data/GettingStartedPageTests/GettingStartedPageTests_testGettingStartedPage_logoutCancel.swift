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

  class GettingStartedPageTests_testGettingStartedPage_logoutCancel : DataProvider {
    override init() {
      super.init()

      parents.append(Parent(parentId: "40a83262-c0c0-4bea-9d39-f6c36c7b3760",
                            username:   "1487973750@2d647629-eae5-4503-b64a-2374cf71ce21.com",
                            password:   "ba6867aae9e8667f",
                            firstName:  "Domenick",
                            lastName:   "Dach",
                            students:   [],
                            thresholds: [],
                            alerts:     []))
    }
  }
}
