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

  class GettingStartedPageTests_testGettingStartedPage_displaysPageObjects : DataProvider {
    override init() {
      super.init()

      parents.append(Parent(parentId: "92c075c5-775c-40b0-a215-43b3f160f7f5",
                            username:   "1487973749@df2f22e2-dc20-4b74-9de2-834035b9c915.com",
                            password:   "64d9dc8bee410586",
                            firstName:  "Dakota",
                            lastName:   "Wolff",
                            students:   [],
                            thresholds: [],
                            alerts:     []))
    }
  }
}
