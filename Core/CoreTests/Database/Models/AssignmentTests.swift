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

import Foundation
import XCTest
@testable import Core

class AssignmentTests: CoreTestCase {

    func testUpdateFromAPIItemWithAPISubmission() {
        let client = databaseClient
        let a = Assignment.make(["name": "a"])
        let api = APIAssignment.make(["name": "api_a", "submission": APISubmission.fixture()])

        XCTAssertNil(a.submission)

        XCTAssertNoThrow( try a.update(fromApiModel: api, in: client, updateSubmission: true) )

        XCTAssertEqual(a.id, api.id.value)
        XCTAssertEqual(a.name, api.name)
        XCTAssertEqual(a.courseID, api.course_id.value)
        XCTAssertEqual(a.details, api.description)
        XCTAssertEqual(a.pointsPossible, api.points_possible)
        XCTAssertEqual(a.dueAt, api.due_at)
        XCTAssertEqual(a.htmlURL, api.html_url)
        XCTAssertEqual(a.gradingType, api.grading_type)
        XCTAssertEqual(a.submissionTypes, api.submission_types)
        XCTAssertEqual(a.position, api.position)

        XCTAssertNotNil(a.submission)
    }

    func testUpdateFromAPIItemWithAPISubmissionButDoNotMutateSubmission() {
        let client = databaseClient
        let a = Assignment.make(["name": "a"])
        let api = APIAssignment.make(["name": "api_a", "submission": APISubmission.fixture()])

        XCTAssertNil(a.submission)

        XCTAssertNoThrow( try a.update(fromApiModel: api, in: client, updateSubmission: false) )

        XCTAssertNil(a.submission)
    }

    func testUpdateFromAPIItemWithExistingSubmission() {
        let client = databaseClient
        let submission: Submission = client.make(["grade": "A"])
        let a: Assignment = client.make(["name": "a", "submission": submission])
        let api = APIAssignment.make(["name": "api_a", "submission": nil])
        XCTAssertNil(api.submission)

        XCTAssertNoThrow( try a.update(fromApiModel: api, in: client, updateSubmission: true) )
        XCTAssertNil(a.submission)

        let list: [Assignment] = client.fetch(NSPredicate(format: "%K == %@", #keyPath(Assignment.id), a.id))
        let result = list.first
        XCTAssertNotNil(result)
        XCTAssertNil(result?.submission)
    }

    func testDetailsScopeOnlyIncludesAssignment() {
        let assignment = Assignment.make(["id": "1"])
        let other = Assignment.make(["id": "2"])
        let list = environment.subscribe(Assignment.self, .details("1"))
        list.performFetch()

        XCTAssertEqual(list.fetchedObjects?.count, 1)
        XCTAssertEqual(list.fetchedObjects?.first, assignment)
        XCTAssertEqual(list.fetchedObjects?.contains(other), false)
    }

    func testCourseListScoppeIsSortedByPosition() {
        let a = Assignment.make(["id": "1", "position": 2, "name": "a"])
        let b = Assignment.make(["id": "2", "position": 1, "name": "b"])
        let list = environment.subscribe(Assignment.self, Assignment.ScopeKeys.courseList("1"))
        list.performFetch()

        XCTAssertEqual(list.fetchedObjects?.count, 2)
        XCTAssertEqual(list.fetchedObjects?.first, b)
        XCTAssertEqual(list.fetchedObjects?.last, a)
    }

    func testCanMakeSubmissions() {
        //  given
        let a = Assignment.make()
        a.submissionTypes = [.online_upload]

        //  when
        let result = a.canMakeSubmissions

        //  then
        XCTAssertTrue(result)
    }

    func testCannotMakeSubmissions() {
        //  given
        let a = Assignment.make()
        a.submissionTypes = [.none]

        //  when
        let result = a.canMakeSubmissions

        //  then
        XCTAssertFalse(result)
    }

    func testCannotMakeSubmissionsOnPaper() {
        //  given
        let a = Assignment.make()
        a.submissionTypes = [.on_paper]

        //  when
        let result = a.canMakeSubmissions

        //  then
        XCTAssertFalse(result)
    }

    func testCannotMakeSubmissionsWithNoSubmissionTypes() {
        //  given
        let a = Assignment.make()
        a.submissionTypes = []

        //  when
        let result = a.canMakeSubmissions

        //  then
        XCTAssertFalse(result)
    }

    func testAllowedUTIsNoneIsEmpty() {
        let a = Assignment.make()
        a.submissionTypes = [.none]
        a.allowedExtensions = ["png"]
        XCTAssertTrue(a.allowedUTIs.isEmpty)
    }

    func testAllowedUTIsAny() {
        let a = Assignment.make()
        a.submissionTypes = [.online_upload]
        a.allowedExtensions = []
        XCTAssertEqual(a.allowedUTIs, [.any])
    }

    func testAllowedUTIsAllowedExtensions() {
        let a = Assignment.make()
        a.submissionTypes = [.online_upload]
        a.allowedExtensions = ["png", "mov", "mp3"]
        let result = a.allowedUTIs
        XCTAssertEqual(result.count, 3)
        XCTAssertTrue(result[0].isImage)
        XCTAssertTrue(result[1].isVideo)
        XCTAssertTrue(result[2].isAudio)
    }

    func testAllowedUTIsAllowedExtensionsVideo() {
        let a = Assignment.make()
        a.submissionTypes = [.online_upload]
        a.allowedExtensions = ["mov", "mp4"]
        let result = a.allowedUTIs
        XCTAssertTrue(result[0].isVideo)
        XCTAssertTrue(result[1].isVideo)
    }

    func testAllowedUTIsMediaRecording() {
        let a = Assignment.make()
        a.submissionTypes = [.media_recording]
        XCTAssertEqual(a.allowedUTIs, [.video, .audio])
    }

    func testAllowedUTIsText() {
        let a = Assignment.make()
        a.submissionTypes = [.online_text_entry]
        XCTAssertEqual(a.allowedUTIs, [.text])
    }

    func testAllowedUTIsURL() {
        let a = Assignment.make()
        a.submissionTypes = [.online_url]
        XCTAssertEqual(a.allowedUTIs, [.url])
    }

    func testAllowedUTIsMultipleSubmissionTypes() {
        let a = Assignment.make()
        a.submissionTypes = [
            .online_upload,
            .online_text_entry,
        ]
        a.allowedExtensions = ["jpeg"]
        let result = a.allowedUTIs
        XCTAssertEqual(result.count, 2)
        XCTAssertTrue(result[0].isImage)
        XCTAssertEqual(result[1], .text)
    }

    func testIsLTIAssignment() {
        let a = Assignment.make()
        a.submissionTypes = [.external_tool]
        XCTAssertTrue(a.isLTIAssignment)
    }
}
