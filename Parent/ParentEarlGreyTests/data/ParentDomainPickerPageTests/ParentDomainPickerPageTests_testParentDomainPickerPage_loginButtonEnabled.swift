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

  class ParentDomainPickerPageTests_testParentDomainPickerPage_loginButtonEnabled : DataProvider {
    override init() {
      super.init()

      parents.append(Parent(parentId: "11724a6b-3d3e-4341-aad6-a9917c0ea7bc",
                            username:   "1487973751@d4014674-a782-42c4-a42a-5a7d7632a17a.com",
                            password:   "2cf0fba68dcfe43c",
                            firstName:  "Zora",
                            lastName:   "Legros",
                            students:   [],
                            thresholds: [],
                            alerts:     []))
    }
  }
}
