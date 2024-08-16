//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

class ConferenceTests: CoreTestCase {

    private enum TestConstants {
        static let date1 = DateComponents(calendar: .current, year: 2020, month: 3, day: 14, hour: 13).date!
        static let date2 = DateComponents(calendar: .current, year: 2020, month: 3, day: 14, hour: 18).date!
    }

    func testProperties() {
        let conference = Conference.make(from: .make(recordings: [.make()]))
        conference.canvasContextID = "bogus"
        XCTAssertEqual(conference.context, .currentUser)
        conference.context = Context(.course, id: "1")
        XCTAssertEqual(conference.context, Context(.course, id: "1"))
        XCTAssertEqual(conference.canvasContextID, "course_1")

        conference.duration = nil
        XCTAssertEqual(conference.duration, nil)
        conference.duration = 3.6
        XCTAssertEqual(conference.duration, 3.6)

        conference.recordings = []
        XCTAssertEqual(conference.recordingsRaw?.count, 0)
        conference.recordings = [.make()]
        XCTAssertEqual(conference.recordingsRaw?.count, 1)
        XCTAssertEqual(conference.recordings?.count, 1)

        conference.startedAt = nil
        conference.endedAt = nil
        XCTAssertEqual(conference.statusText, "Not Started")
        XCTAssertEqual(conference.statusLongText.string, "Not Started")
        XCTAssertEqual(conference.statusColor, .textDark)
        conference.startedAt = TestConstants.date1
        XCTAssertEqual(conference.statusText, "In Progress")
        XCTAssertEqual(conference.statusLongText.string, "In Progress | Started " + TestConstants.date1.dateTimeString)
        XCTAssertEqual(conference.statusColor, .textSuccess)
        conference.endedAt = TestConstants.date2
        XCTAssertEqual(conference.statusText, "Concluded " + TestConstants.date2.dateTimeString)
        XCTAssertEqual(conference.statusLongText.string, "Concluded " + TestConstants.date2.dateTimeString)
        XCTAssertEqual(conference.statusColor, .textDark)
    }

    func testGetConferences() {
        let useCase = GetConferences(context: .group("7"))
        XCTAssertEqual(useCase.cacheKey, "groups/7/conferences")
        XCTAssertEqual(useCase.scope, Scope(
            predicate: NSPredicate(format: "%K == %@", #keyPath(Conference.canvasContextID), "group_7"),
            order: [
                NSSortDescriptor(key: #keyPath(Conference.isConcluded), ascending: true),
                NSSortDescriptor(key: #keyPath(Conference.order), ascending: false, naturally: true),
            ],
            sectionNameKeyPath: #keyPath(Conference.isConcluded)
        ))
        XCTAssertEqual(useCase.request.path, "groups/7/conferences")

        useCase.write(response: nil, urlResponse: nil, to: databaseClient)
        var list: [Conference] = databaseClient.fetch(scope: useCase.scope)
        XCTAssertEqual(list.count, 0)

        useCase.write(response: GetConferencesRequest.Response(conferences: [
            .make(id: "1"),
            .make(id: "2"),
            .make(ended_at: Clock.now, id: "3"),
            .make(id: "4", started_at: Clock.now),
        ]), urlResponse: nil, to: databaseClient)
        list = databaseClient.fetch(scope: useCase.scope)
        XCTAssertEqual(list.map { $0.id }, [ "4", "2", "1", "3" ])
    }
}
