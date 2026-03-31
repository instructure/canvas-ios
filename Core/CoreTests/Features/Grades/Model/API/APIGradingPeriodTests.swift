//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import XCTest
@testable import Core

class APIGradingPeriodTests: XCTestCase {
    func testGetGradingPeriodsRequest() {
        let req = GetGradingPeriodsRequest(courseID: "1")
        XCTAssertEqual(req.path, "courses/1/grading_periods")
    }

    func testGetNextPropagatesCustomDecode() throws {
        let req = GetGradingPeriodsRequest(courseID: "2054")
        let nextURL = URL(string: "https://canvas.instructure.com/api/v1/courses/2054/grading_periods?page=2")!
        let headers = ["Link": "<\(nextURL.absoluteString)>; rel=\"next\""]
        let urlResponse = HTTPURLResponse(url: nextURL, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: headers)!

        let nextRequest = try XCTUnwrap(req.getNext(from: urlResponse))

        let period = APIGradingPeriod.make(id: "99", title: "Test Period")
        let jsonData = try APIJSONEncoder().encode(APIGradingPeriodResponse(grading_periods: [period]))

        let result = try nextRequest.decode(jsonData)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.id.value, "99")
        XCTAssertEqual(result.first?.title, "Test Period")
    }
}
