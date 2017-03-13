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

  class GettingStartedPageTests_testGettingStartedPage_logout : DataProvider {
    override init() {
      super.init()

      parents.append(Parent(parentId: "2a5c8048-a092-4ef9-bf94-86e0125e808d",
                            username:   "1487973750@894111bb-59ba-4346-a8c6-b001737a8f84.com",
                            password:   "180f52df39ee0a9e",
                            firstName:  "Lillian",
                            lastName:   "Kuhic",
                            students:   [],
                            thresholds: [],
                            alerts:     []))
    }
  }
}
