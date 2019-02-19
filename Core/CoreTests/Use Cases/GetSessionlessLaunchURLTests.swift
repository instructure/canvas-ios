//
// Copyright (C) 2018-present Instructure, Inc.
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

class GetSessionlessLaunchURLTests: CoreTestCase {

    func testGetSessionlessLaunchURL() {
        let context = ContextModel(.course, id: "1")
        let request = GetSessionlessLaunchURLRequest(context: context, id: "2", url: URL(string: "https://google.com")!, assignmentID: "3", moduleItemID: nil, launchType: .assessment)
        let responseBody = APIGetSessionlessLaunchResponse(id: "2", name: "An external tool", url: URL(string: "https://instructure.com")!)
        api.mock(request, value: responseBody, response: nil, error: nil)

        let getSessionlessLaunchURL = GetSessionlessLaunchURL(
            api: api,
            context: context,
            id: "2",
            url: URL(string: "https://google.com")!,
            launchType: .assessment,
            assignmentID: "3",
            moduleItemID: nil
        )
        addOperationAndWait(getSessionlessLaunchURL)

        XCTAssertEqual(getSessionlessLaunchURL.response, responseBody)
    }

}
