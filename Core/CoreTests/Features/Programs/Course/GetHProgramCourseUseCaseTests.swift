//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

final class GetHProgramCourseUseCaseTests: CoreTestCase {

    func testCacheKey() {
        // Given
        let programs = [GetHProgramCourseUseCase.RequestModel(programId: "123", courseIds: ["200", "300"])]
        let testee = GetHProgramCourseUseCase(programs: programs)
        // Then
        let key = "123-200,300"
        XCTAssertEqual(testee.cacheKey, key)
    }

    func testRequest() {
        // Given
        let programs = [GetHProgramCourseUseCase.RequestModel(programId: "123", courseIds: ["200", "300"])]
        let testee = GetHProgramCourseUseCase(programs: programs)
        // When
        let requst = testee.request
        // Then
        XCTAssertEqual(requst.variables.ids, ["200", "300"])
    }

    func testWriteResponse() {
        // Given
        let response = HProgramCourseStub.getProgramCourse()
        let programs = [GetHProgramCourseUseCase.RequestModel(programId: "123", courseIds: ["1"])]
        let testee = GetHProgramCourseUseCase(programs: programs)
        // When
        testee.write(response: .init(data: .init(courses: [response])), urlResponse: nil, to: databaseClient)
        let savedData: [CDHProgramCourse] = databaseClient.fetch()
        // Then
        XCTAssertEqual(savedData.count, 1)
        XCTAssertEqual(savedData.first?.courseID, "1")
        XCTAssertEqual(savedData.first?.programID, "123")
        XCTAssertEqual(savedData.first?.courseName, "Test Course")
        XCTAssertEqual(savedData.first?.moduleItems.count, 4)
    }

    func testMakeReqestSuccess() {
        // Given
        let courses = HProgramCourseStub.getProgramCourse()
        let programs = [GetHProgramCourseUseCase.RequestModel(programId: "123", courseIds: ["1"])]
        let testee = GetHProgramCourseUseCase(programs: programs)
        let response = GetHProgramCourseResponse(data: .init(courses: [courses]))
        let expection = expectation(description: "Wait for completion")

        // When
        api.mock(GetHProgramCourseRequest(courseIDs: ["1"]), value: response)
        testee.makeRequest(environment: environment) { response, _, _ in
            expection.fulfill()
            XCTAssertEqual(response?.data?.courses?.count, 1)
        }
        wait(for: [expection], timeout: 0.2)
    }

    func testMakeReqestFail() {
        // Given
        let courses = HProgramCourseStub.getProgramCourse()
        let programs = [GetHProgramCourseUseCase.RequestModel(programId: "123", courseIds: ["1"])]
        let testee = GetHProgramCourseUseCase(programs: programs)
        let response = GetHProgramCourseResponse(data: .init(courses: [courses]))
        let expection = expectation(description: "Wait for completion")

        // When
        api.mock(GetHProgramCourseRequest(courseIDs: ["1"]), value: response, error: URLError(.badURL))
        testee.makeRequest(environment: environment) { response, _, error in
            expection.fulfill()
            XCTAssertNil(response)
            XCTAssertEqual(error?.localizedDescription, URLError(.badURL).localizedDescription)
        }
        wait(for: [expection], timeout: 0.2)
    }
}
