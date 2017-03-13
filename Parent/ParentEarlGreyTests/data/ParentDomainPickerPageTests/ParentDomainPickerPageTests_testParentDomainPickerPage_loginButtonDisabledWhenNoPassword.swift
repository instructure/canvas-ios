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

  class ParentDomainPickerPageTests_testParentDomainPickerPage_loginButtonDisabledWhenNoPassword : DataProvider {
    override init() {
      super.init()

      parents.append(Parent(parentId: "323b47d2-a320-4e89-9098-59f2cec6a309",
                            username:   "1487973750@aefc3d46-5ab9-4860-b2da-533b92e4b8da.com",
                            password:   "a48906a210fa1b68",
                            firstName:  "Emilia",
                            lastName:   "Ziemann",
                            students:   [],
                            thresholds: [],
                            alerts:     []))
    }
  }
}
