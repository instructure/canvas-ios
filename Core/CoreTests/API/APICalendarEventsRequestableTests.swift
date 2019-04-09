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

class APICalendarEventsRequestableTests: XCTestCase {

    var ctx = ContextModel(.course, id: "1")
    let url = URL(string: "https://foo.instructure.com")!
    let mockDate = Date(fromISOString: "2019-12-25T14:24:37Z")!

    override func setUp() {
        super.setUp()
        ctx = ContextModel(.course, id: "1")
        Clock.mockNow(mockDate)
    }

    override func tearDown() {
        Clock.reset()
        super.tearDown()
    }

    func testGetCalendarEvents() {
        let requestable = GetCalendarEventsRequest(context: ctx)
        let r = try? requestable.urlRequest(relativeTo: url, accessToken: nil, actAsUserID: nil)
        XCTAssertEqual(r?.url?.absoluteString, "https://foo.instructure.com/api/v1/calendar_events?context_codes%5B%5D=course_1&type=event&start_date=2017-12-25&end_date=2020-12-25&per_page=100")
    }
}
