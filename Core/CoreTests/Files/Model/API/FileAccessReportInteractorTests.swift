//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

@testable import Core
import XCTest

class FileAccessReportInteractorTests: CoreTestCase {

    func testFinishesOnSuccessfulReport() {
        // MARK: - GIVEN
        let api = API(baseURL: URL(string: "https://instructure.com")!)

        // Mock Web Session Response
        let expectedWebSessionURL = URL(string: "https://instructure.com/courses/1/files/2")!
        api.mock(GetWebSessionRequest(to: expectedWebSessionURL),
                 value: .init(session_url: URL(string: "https://instructure.com/session")!,
                              requires_terms_acceptance: false))

        // Mock File Access Response
        let expectedReporterURL = URL(string: "https://instructure.com/session?preview=1")!
        api.mock(expectedReporterURL,
                 response: HTTPURLResponse(url: expectedReporterURL,
                                           statusCode: 200,
                                           httpVersion: "1.1",
                                           headerFields: nil))

        // MARK: - WHEN
        let testee = FileAccessReportInteractor(context: .course("1"), fileID: "2", api: api)

        // MARK: - THEN
        XCTAssertFinish(testee.reportFileAccess())
    }
}
