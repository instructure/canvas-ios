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

class APIExternalToolRequestableTests: XCTestCase {
    func testGetSessionlessLaunchURL() {
        let request = GetSessionlessLaunchURLRequest(
            context: ContextModel(.course, id: "1"),
            id: "2",
            url: URL(string: "https://google.com")!,
            assignmentID: "3",
            moduleItemID: "4",
            launchType: .module_item
        )

        XCTAssertEqual(request.path, "courses/1/external_tools/sessionless_launch")
        XCTAssertEqual(request.queryItems, [
            URLQueryItem(name: "id", value: "2"),
            URLQueryItem(name: "launch_type", value: "module_item"),
            URLQueryItem(name: "url", value: "https://google.com"),
            URLQueryItem(name: "assignment_id", value: "3"),
            URLQueryItem(name: "module_item_id", value: "4"),
        ])
    }
}
