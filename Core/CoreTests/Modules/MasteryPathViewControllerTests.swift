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

import Foundation
@testable import Core
@testable import TestsFoundation
import XCTest

class MasteryPathViewControllerTests: CoreTestCase {
    lazy var masteryPath = MasteryPath.save(.make(), in: databaseClient)
    lazy var controller = MasteryPathViewController.create(masteryPath: masteryPath)

    func testLayout() {
        masteryPath = MasteryPath.save(.make(
            locked: false,
            assignment_sets: [
                .make(id: "1", position: 0, assignments: [
                    .make(position: 0, model: .make(id: "1", name: "A1", points_possible: 10)),
                    .make(position: 1, model: .make(course_id: "1", id: "2", name: "A2"))
                ]),
                .make(id: "2", position: 1, assignments: [
                    .make(position: 0, model: .make(id: "3", name: "A3"))
                ])
            ],
            selected_set_id: nil
        ), in: databaseClient)
        masteryPath.moduleItem = ModuleItem.make(from: .make(), forCourse: "1", in: databaseClient)
        controller.view.layoutIfNeeded()
        XCTAssertEqual(controller.stackView.arrangedSubviews.count, 3)
        let option1 = controller.stackView.arrangedSubviews[0] as! MasteryPathAssignmentSetView
        XCTAssertEqual(option1.stackView.arrangedSubviews.count, 3)
        let assignment1 = option1.stackView.arrangedSubviews[0] as! MasteryPathAssignmentCell
        XCTAssertEqual(assignment1.nameLabel.text, "A1")
        XCTAssertEqual(assignment1.pointsLabel.text, "10 points")
        let assignment2 = option1.stackView.arrangedSubviews[1] as! MasteryPathAssignmentCell
        XCTAssertEqual(assignment2.nameLabel.text, "A2")
        XCTAssertTrue(assignment2.accessibilityTraits.contains(.button))
        XCTAssertFalse(assignment2.accessibilityTraits.contains(.selected))
        assignment2.onTap(assignment2.gestureRecognizers!.first as! UITapGestureRecognizer)
        XCTAssertTrue(router.lastRoutedTo("/courses/1/assignments/2", withOptions: .detail))
        XCTAssertTrue(assignment2.accessibilityTraits.contains(.selected))
        controller.viewWillAppear(true)
        XCTAssertFalse(assignment2.accessibilityTraits.contains(.selected))
        let select1 = option1.stackView.arrangedSubviews[2] as! MasteryPathAssignmentSetSelectCell
        XCTAssertEqual(select1.button.title(for: .normal), "Select")
        select1.button.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual(select1.button.title(for: .normal), "Selected!")

        XCTAssertNotNil(controller.stackView.arrangedSubviews[1] as? MasteryPathAssignmentSetDivider)

        let option2 = controller.stackView.arrangedSubviews[2] as! MasteryPathAssignmentSetView
        let select2 = option2.stackView.arrangedSubviews[1] as! MasteryPathAssignmentSetSelectCell
        XCTAssertEqual(select2.button.title(for: .normal), "Select")
        select2.button.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual(select2.button.title(for: .normal), "Selected!")
        XCTAssertEqual(select1.button.title(for: .normal), "Select")
        select2.button.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual(select2.button.title(for: .normal), "Select")
    }
}
