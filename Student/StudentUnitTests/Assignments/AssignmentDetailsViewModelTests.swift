//
// Copyright (C) 2018-present Instructure, Inc.
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
@testable import Student

class AssignmentDetailsViewModelTests: XCTestCase {

    var model: AssignmentDetailsViewModel!
    let dateFormatter = DateFormatter()
    var now: Date!
    let aName = "assignemnt"
    let points: Double  = 100

    override func setUp() {
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'"
        now = dateFormatter.date(from: "2018-10-01")
        model = AssignmentDetailsViewModel(name: aName, pointsPossible: points, dueAt: now, submissionTypes: [.online_text_entry])
    }

    func testNilDueDate() {
        //  given
        model = AssignmentDetailsViewModel(name: aName, pointsPossible: points, dueAt: nil, submissionTypes: [])

        //  when
        let result = model.dueText

        //  then
        XCTAssertNil(result)
    }

    func testDueDate() {
        //  given
        model = AssignmentDetailsViewModel(name: aName, pointsPossible: points, dueAt: now, submissionTypes: [])

        //  when
        let result = model.dueText

        //  then
        XCTAssertEqual(result, "Oct 1, 2018 at 12:00 AM")
    }

    func testPointsPossibleWithNil() {
        //  given
        model = AssignmentDetailsViewModel(name: aName, pointsPossible: nil, dueAt: now, submissionTypes: [])

        //  when
        let result = model.pointsPossibleText

        //  then
        XCTAssertNil(result)
    }

    func testPointsPossibleWithLargeInput() {
        //  given
        model = AssignmentDetailsViewModel(name: aName, pointsPossible: 99999, dueAt: now, submissionTypes: [])

        //  when
        let result = model.pointsPossibleText

        //  then
        XCTAssertEqual(result, "99,999 pts")
    }

    func testPointsPossibleWithSmallInput() {
        //  given
        model = AssignmentDetailsViewModel(name: aName, pointsPossible: 0.001, dueAt: now, submissionTypes: [])

        //  when
        let result = model.pointsPossibleText

        //  then
        XCTAssertEqual(result, "0.001 pts")
    }

    func testSubmissionTypeTextNone() {
        model = AssignmentDetailsViewModel(name: aName, pointsPossible: points, dueAt: now, submissionTypes: [])

        //  when
        let result = model.submissionTypeText

        //  then
        XCTAssertEqual(result, "")
    }
}
