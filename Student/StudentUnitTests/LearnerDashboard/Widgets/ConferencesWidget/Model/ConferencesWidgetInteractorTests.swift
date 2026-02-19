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
@testable import Student
@testable import TestsFoundation
import XCTest

final class ConferencesWidgetInteractorTests: StudentTestCase {

    private static let testData = (
        courseId: "course1",
        courseName: "course name",
        groupId: "group1",
        groupName: "group name",
        id1: "conf1",
        title1: "conference title 1",
        id2: "conf2",
        title2: "conference title 2",
        url: URL(string: "https://example.com/conference")!
    )
    private lazy var testData = Self.testData

    private var testee: ConferencesWidgetInteractorLive!
    private var coursesInteractor: CoursesInteractorMock!

    override func setUp() {
        super.setUp()
        coursesInteractor = CoursesInteractorMock()
    }

    override func tearDown() {
        testee = nil
        coursesInteractor = nil
        super.tearDown()
    }

    // MARK: - getConferences

    func test_getConferences_shouldCombineConferencesAndCourses() {
        setupConferencesAndCourses()
        testee = makeInteractor()

        let testData = testData
        XCTAssertFirstValue(testee.getConferences(ignoreCache: false), timeout: 5) { result in
            XCTAssertEqual(result.count, 2)

            XCTAssertEqual(result.first?.id, testData.id1)
            XCTAssertEqual(result.first?.title, testData.title1)
            XCTAssertEqual(result.first?.contextName, testData.courseName)
            XCTAssertEqual(result.first?.joinRoute, "courses/\(testData.courseId)/conferences/\(testData.id1)/join")
            XCTAssertEqual(result.first?.joinUrl, testData.url)

            XCTAssertEqual(result.last?.id, testData.id2)
            XCTAssertEqual(result.last?.title, testData.title2)
            XCTAssertEqual(result.last?.contextName, testData.groupName)
            XCTAssertEqual(result.last?.joinRoute, "groups/\(testData.groupId)/conferences/\(testData.id2)/join")
            XCTAssertEqual(result.last?.joinUrl, nil)
        }
    }

    func test_getConferences_shouldFilterConferencesWithMissingContext() {
        setupConferencesWithMissingContext()
        testee = makeInteractor()

        XCTAssertFirstValue(testee.getConferences(ignoreCache: false), timeout: 5) { result in
            XCTAssertEqual(result.count, 1)
            XCTAssertEqual(result.first?.id, self.testData.id1)
        }
    }

    // MARK: - dismissConference

    func test_dismissConference_shouldMarkConferenceAsIgnored() {
        let conference = setupConference()
        testee = makeInteractor()

        XCTAssertEqual(conference.isIgnored, false)

        XCTAssertFinish(testee.dismissConference(id: conference.id), timeout: 5)

        databaseClient.refresh(conference, mergeChanges: false)
        XCTAssertEqual(conference.isIgnored, true)
    }

    func test_dismissConference_shouldPersistToDatabase() {
        let conference = setupConference()
        testee = makeInteractor()

        XCTAssertFinish(testee.dismissConference(id: conference.id), timeout: 5)

        let savedConference: Conference? = databaseClient.fetch(scope: .where(\Conference.id, equals: conference.id)).first
        XCTAssertEqual(savedConference?.isIgnored, true)
    }

    func test_dismissConference_withNonExistentId_shouldNotFail() {
        testee = makeInteractor()

        XCTAssertFinish(testee.dismissConference(id: "nonexistent"), timeout: 5)
    }

    // MARK: - Private helpers

    private func makeInteractor() -> ConferencesWidgetInteractorLive {
        ConferencesWidgetInteractorLive(
            coursesInteractor: coursesInteractor,
            env: env
        )
    }

    private func setupConferencesAndCourses() {
        let courseConference = APIConference.make(
            context_id: ID(testData.courseId),
            context_type: "Course",
            id: testData.id1,
            join_url: testData.url,
            started_at: Clock.now.addMinutes(-30),
            title: testData.title1
        )
        let groupConference = APIConference.make(
            context_id: ID(testData.groupId),
            context_type: "Group",
            id: testData.id2,
            started_at: Clock.now.addMinutes(-40),
            title: testData.title2
        )

        api.mock(
            GetLiveConferencesRequest(),
            value: GetConferencesRequest.Response(conferences: [courseConference, groupConference])
        )

        let course = Course.save(
            .make(id: ID(testData.courseId), name: testData.courseName),
            in: databaseClient
        )
        let group = CDAllCoursesGroupItem.save(
            .make(id: ID(testData.groupId), name: testData.groupName),
            in: databaseClient
        )

        try? databaseClient.save()

        coursesInteractor.mockCoursesResult = .make(
            allCourses: [course],
            groups: [group]
        )
    }

    private func setupConferencesWithMissingContext() {
        let courseConference = APIConference.make(
            context_id: ID(testData.courseId),
            context_type: "Course",
            id: testData.id1,
            started_at: Clock.now.addMinutes(-30),
            title: testData.title1
        )
        let nonexistentConference = APIConference.make(
            context_id: ID("nonexistent"),
            context_type: "Course",
            id: testData.id2,
            started_at: Clock.now.addMinutes(-30),
            title: testData.title2
        )

        api.mock(
            GetLiveConferencesRequest(),
            value: GetConferencesRequest.Response(conferences: [courseConference, nonexistentConference])
        )

        let course = Course.save(
            .make(id: ID(testData.courseId), name: testData.courseName),
            in: databaseClient
        )

        try? databaseClient.save()

        coursesInteractor.mockCoursesResult = .make(allCourses: [course])
    }

    private func setupConference() -> Conference {
        let conference = Conference.save(
            .make(
                context_id: ID(testData.courseId),
                context_type: "Course",
                id: testData.id1,
                started_at: Clock.now.addMinutes(-30),
                title: testData.title1
            ),
            in: databaseClient,
            context: Context(.course, id: testData.courseId)
        )

        try? databaseClient.save()

        return conference
    }
}
