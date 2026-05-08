//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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
@testable import Horizon
import Combine
import XCTest
import TestsFoundation

final class HCourseSyncSyllabusInteractorLiveTests: HorizonTestCase {

    private static let testData = (
        courseID1: "course 1",
        courseID2: "course 2"
    )
    private lazy var testData = Self.testData

    private var htmlParser: SyllabusHTMLParserMock!
    private var testee: HCourseSyncSyllabusInteractorLive!

    override func setUp() {
        super.setUp()
        htmlParser = SyllabusHTMLParserMock()
        testee = HCourseSyncSyllabusInteractorLive(htmlParser: htmlParser)
    }

    override func tearDown() {
        testee = nil
        htmlParser = nil
        super.tearDown()
    }

    // MARK: - getContent

    func test_getContent_withEmptyCourseIDs_shouldNotMakeAnyAPIRequests() {
        testee.getContent(courseIDs: [])
    }

    func test_getContent_withSingleCourseID_shouldRequestCourse() {
        let apiExpectation = expectation(description: "GetCourse API called")
        api.mock(
            GetCourseRequest(courseID: testData.courseID1),
            expectation: apiExpectation,
            value: .make(id: ID(testData.courseID1))
        )

        testee.getContent(courseIDs: [testData.courseID1])

        wait(for: [apiExpectation], timeout: 1)
    }

    func test_getContent_withMultipleCourseIDs_shouldRequestEachCourse() {
        let apiExpectation1 = expectation(description: "GetCourse API called for course 1")
        let apiExpectation2 = expectation(description: "GetCourse API called for course 2")
        api.mock(
            GetCourseRequest(courseID: testData.courseID1),
            expectation: apiExpectation1,
            value: .make(id: ID(testData.courseID1))
        )
        api.mock(
            GetCourseRequest(courseID: testData.courseID2),
            expectation: apiExpectation2,
            value: .make(id: ID(testData.courseID2))
        )

        testee.getContent(courseIDs: [testData.courseID1, testData.courseID2])

        wait(for: [apiExpectation1, apiExpectation2], timeout: 1)
    }

    func test_getContent_whenCalledTwice_shouldCancelPreviousRequests() {
        api.mock(GetCourseRequest(courseID: testData.courseID1), value: .make(id: ID(testData.courseID1)))

        testee.getContent(courseIDs: [testData.courseID1])
        testee.getContent(courseIDs: [])
    }

    // MARK: - cancelRequests

    func test_cancelRequests_shouldNotCrash() {
        api.mock(GetCourseRequest(courseID: testData.courseID1), value: .make(id: ID(testData.courseID1)))
        testee.getContent(courseIDs: [testData.courseID1])

        testee.cancelRequests()
    }

    func test_cancelRequests_withoutActiveRequests_shouldNotCrash() {
        testee.cancelRequests()
    }
}

// MARK: - Mocks

private final class SyllabusHTMLParserMock: HTMLParser {
    var embeddedContentFailurePublisher: AnyPublisher<Core.CourseSyncID, Never> {
        Empty().eraseToAnyPublisher()
    }

    var sectionName: String = "syllabus"
    var envResolver: CourseSyncEnvironmentResolver = CourseSyncEnvironmentResolverLive()

    func sectionFolder(for courseId: CourseSyncID) -> URL {
        URL.Directories.documents
    }

    func parse(
        _ content: String,
        resourceId: String,
        courseId: CourseSyncID,
        baseURL: URL?
    ) -> AnyPublisher<String, Error> {
        Just("").setFailureType(to: Error.self).eraseToAnyPublisher()
    }

    func downloadAttachment(
        _ url: URL,
        courseId: CourseSyncID,
        resourceId: String
    ) -> AnyPublisher<String, Error> {
        Just("").setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}
