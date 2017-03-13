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

  class ParentDomainPickerPageTests_testParentDomainPickerPage_loginButton : DataProvider {
    override init() {
      super.init()

      parents.append(Parent(parentId: "14e84d7d-1220-4a7a-961b-269f80fee697",
                            username:   "1487973751@8434bd6e-96f7-40d4-bd59-464d0acb7fb0.com",
                            password:   "ce7e4e1cbb94745a",
                            firstName:  "Ruby",
                            lastName:   "Legros",
                            students:   [],
                            thresholds: [],
                            alerts:     []))
    }
  }
}
