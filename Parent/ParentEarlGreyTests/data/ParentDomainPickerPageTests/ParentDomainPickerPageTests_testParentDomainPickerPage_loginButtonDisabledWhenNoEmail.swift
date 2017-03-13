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

  class ParentDomainPickerPageTests_testParentDomainPickerPage_loginButtonDisabledWhenNoEmail : DataProvider {
    override init() {
      super.init()

      parents.append(Parent(parentId: "23a8da2b-5625-4e9b-98ee-2fb616ab71a1",
                            username:   "1487973751@e50cfd77-71f1-4343-a095-acd15946624d.com",
                            password:   "69d258cd83fe2aee",
                            firstName:  "Josh",
                            lastName:   "Cruickshank",
                            students:   [],
                            thresholds: [],
                            alerts:     []))
    }
  }
}
