//
// Copyright (C) 2019-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
