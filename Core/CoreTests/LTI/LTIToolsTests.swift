//
// Copyright (C) 2019-present Instructure, Inc.
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

import XCTest
@testable import Core

class LTIToolsTests: CoreTestCase {
    func testGetSessionlessLaunchURL() {
        let tools = LTITools(
            env: environment,
            context: ContextModel(.course, id: "1"),
            id: nil,
            url: nil,
            launchType: nil,
            assignmentID: nil,
            moduleItemID: nil
        )
        let request = GetSessionlessLaunchURLRequest(context: ContextModel(.course, id: "1"), id: nil, url: nil, assignmentID: nil, moduleItemID: nil, launchType: nil)
        let actualURL = URL(string: "/someplace")!

        api.mock(request)
        var url: URL?
        let doneNil = expectation(description: "callback completed")
        tools.getSessionlessLaunchURL { result in
            url = result
            doneNil.fulfill()
        }
        wait(for: [doneNil], timeout: 1)
        XCTAssertNil(url)

        api.mock(request, value: APIGetSessionlessLaunchResponse(id: "", name: "", url: actualURL), error: APIRequestableError.invalidPath(""))
        let doneError = expectation(description: "callback completed")
        tools.getSessionlessLaunchURL { result in
            url = result
            doneError.fulfill()
        }
        wait(for: [doneError], timeout: 1)
        XCTAssertNil(url)

        api.mock(request, value: APIGetSessionlessLaunchResponse(id: "", name: "", url: actualURL))
        let doneValue = expectation(description: "callback completed")
        tools.getSessionlessLaunchURL { result in
            url = result
            doneValue.fulfill()
        }
        wait(for: [doneValue], timeout: 1)
        XCTAssertEqual(url, actualURL)
    }
}
