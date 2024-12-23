//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

import SwiftUI
import XCTest
@testable import Core

class K5ScheduleWeekViewModelTests: CoreTestCase {

    func testCreatesViewModelsFromAPIData() {
        let weekStart = Date()
        let weekEnd = weekStart.inCalendar.addDays(7)
        let weekRange = weekStart..<weekEnd
        let testee = K5ScheduleWeekViewModel(weekRange: weekStart..<weekEnd, isTodayButtonAvailable: true, days: [
            K5ScheduleDayViewModel(range: weekStart..<weekStart.add(.day, number: 1), calendar: .current),
            K5ScheduleDayViewModel(range: weekStart.add(.day, number: 1)..<weekStart.add(.day, number: 2), calendar: .current)
        ])

        let plannablesRequest = GetPlannablesRequest(userID: nil, startDate: weekRange.lowerBound, endDate: weekRange.upperBound, contextCodes: [], filter: "")
        let plannablesResponse: [APIPlannable] = [.make(plannable_date: weekStart.add(.second, number: 1))]
        api.mock(plannablesRequest, value: plannablesResponse)
        let courseRequest = GetCourses(enrollmentState: nil)
        let courseResponse: [APICourse] = [.make(image_download_url: "a.com")]
        api.mock(courseRequest, value: courseResponse)

        let viewModelUpdateEvent = expectation(description: "View Model Updated")
        let modelChangeObservation = testee.objectWillChange.sink {
            viewModelUpdateEvent.fulfill()
        }

        testee.viewDidAppear()
        wait(for: [viewModelUpdateEvent], timeout: 0.1)

        let today = testee.days[0]
        XCTAssertTrue(testee.isTodayModel(today))
        XCTAssertEqual(today.weekday, "Today")
        switch today.subjects {
        case .data(let subjectModels):
            XCTAssertEqual(subjectModels[0].subject.name, "Assignment Grades")
            XCTAssertEqual(subjectModels[0].subject.route, URL(string: "courses/1")!)
            XCTAssertEqual(subjectModels[0].subject.color, Color(UIColor.textDark))
            XCTAssertEqual(subjectModels[0].subject.image, URL(string: "a.com")!)

            XCTAssertTrue(subjectModels[0].entries[0].dueText.hasPrefix("Due: "))
            XCTAssertEqual(subjectModels[0].entries[0].title, "assignment a")
            XCTAssertTrue(subjectModels[0].entries[0].isTappable)
            XCTAssertEqual(subjectModels[0].entries[0].leading, .checkbox(isChecked: false))
        default:
            XCTFail("There should be an event for today")
        }

        let tomorrow = testee.days[1]
        XCTAssertFalse(testee.isTodayModel(tomorrow))
        XCTAssertEqual(tomorrow.weekday, "Tomorrow")
        switch tomorrow.subjects {
        case .empty:
            break
        default:
            XCTFail("There should be no events for tomorrow")
        }

        modelChangeObservation.cancel()
    }
}
