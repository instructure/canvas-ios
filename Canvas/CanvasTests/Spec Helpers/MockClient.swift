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

import SoAutomated
import CanvasKeymaster

class MockClient: CKIClient {
    var mockUser: User!

    init(user: User) {
        super.init(baseURL: user.session.baseURL, token: user.session.token)
        self.mockUser = user
    }

    override var currentUser: CKIUser {
        let user = CKIUser()
        user?.loginID = mockUser.id
        return user!
    }


    // MARK: Required Stuff

    override init(baseURL url: URL?, sessionConfiguration configuration: URLSessionConfiguration?) {
        super.init(baseURL: url, sessionConfiguration: configuration)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
