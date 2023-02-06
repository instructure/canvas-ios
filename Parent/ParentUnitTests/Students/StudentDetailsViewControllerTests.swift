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
@testable import Parent
import TestsFoundation

class StudentDetailsViewControllerTests: ParentTestCase {
    lazy var controller = StudentDetailsViewController.create(studentID: "1")

    override func setUp() {
        super.setUp()
        User.make(from: .make(id: "1", short_name: "Legion", pronouns: "They/Them"))
        api.mock(controller.thresholds, value: [
            .make(id: "1", user_id: "1", alert_type: .courseGradeLow, threshold: 65),
            .make(id: "2", user_id: "1", alert_type: .assignmentMissing, threshold: nil),
        ])
    }

    func testLayout() throws {
        let nav = UINavigationController(rootViewController: controller)
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)
        XCTAssertEqual(nav.navigationBar.barTintColor?.hexString, ColorScheme.observee("1").color.darkenToEnsureContrast(against: .white).hexString)
        XCTAssertEqual(controller.nameLabel.text, "Legion (They/Them)")

        for (index, type) in AlertThresholdType.allCases.enumerated() {
            let label = controller.alertLabels.first { $0.tag == index }
            XCTAssertEqual(label?.text, type.name)
            if type.isPercent {
                let field = try XCTUnwrap(controller.alertFields.first { $0.tag == index })
                XCTAssertEqual(field.accessibilityLabel, type.name)
                XCTAssertEqual(field.text, type == .courseGradeLow ? "65" : "")
                XCTAssert(field.delegate === controller)
            } else {
                let toggle = try XCTUnwrap(controller.alertSwitches.first { $0.tag == index })
                XCTAssertEqual(toggle.accessibilityLabel, type.name)
                XCTAssertEqual(toggle.isOn, type == .assignmentMissing)
            }
        }

        let cGradeHigh = try XCTUnwrap(controller.alertFields.first { $0.tag == 0 })
        cGradeHigh.text = "50"
        cGradeHigh.sendActions(for: .editingDidEnd)
        XCTAssertEqual((router.presented as? UIAlertController)?.message, "You cannot set a high threshold that is lower or equal to a previously set low threshold.")
        XCTAssertEqual(cGradeHigh.text, "")

        api.mock(UpdateAlertThreshold(thresholdID: "1", value: 70, alertType: .courseGradeLow), value: .make(
            id: "1",
            user_id: "1",
            alert_type: .courseGradeLow,
            threshold: 70
        ))
        let cGradeLow = try XCTUnwrap(controller.alertFields.first { $0.tag == 1 })
        cGradeLow.text = "70"
        cGradeLow.sendActions(for: .editingDidEnd)
        XCTAssertEqual(controller.threshold(for: .courseGradeLow)?.value, 70)

        api.mock(RemoveAlertThreshold(thresholdID: controller.threshold(for: .assignmentMissing)!.id))
        let aMissing = try XCTUnwrap(controller.alertSwitches.first { $0.tag == 2 })
        aMissing.isOn = false
        aMissing.sendActions(for: .valueChanged)
        XCTAssertNil(controller.threshold(for: .assignmentMissing))

        api.mock(CreateAlertThreshold(userID: "1", value: 90, alertType: .assignmentGradeHigh), value: APIAlertThreshold.make(
            id: "3",
            user_id: "1",
            alert_type: .assignmentGradeHigh,
            threshold: 90
        ))
        let aGradeHigh = try XCTUnwrap(controller.alertFields.first { $0.tag == 3 })
        aGradeHigh.text = "90"
        aGradeHigh.sendActions(for: .editingDidEnd)
        XCTAssertEqual(controller.threshold(for: .assignmentGradeHigh)?.value, 90)

        let aGradeLow = try XCTUnwrap(controller.alertFields.first { $0.tag == 4 })
        aGradeLow.text = "bogus"
        aGradeLow.sendActions(for: .editingDidEnd)
        XCTAssertEqual((router.presented as? UIAlertController)?.message, "The value must a number between 0 and 100")
        XCTAssertEqual(aGradeLow.text, "")

        aGradeLow.text = "255"
        aGradeLow.sendActions(for: .editingDidEnd)
        XCTAssertEqual((router.presented as? UIAlertController)?.message, "The value must a number between 0 and 100")
        XCTAssertEqual(aGradeLow.text, "")

        aGradeLow.text = "95"
        XCTAssertEqual(aGradeLow.delegate?.textFieldShouldReturn?(aGradeLow), true)
        aGradeLow.sendActions(for: .editingDidEnd)
        XCTAssertEqual((router.presented as? UIAlertController)?.message, "You cannot set a low threshold that is higher or equal to a previously set high threshold.")
        XCTAssertEqual(aGradeLow.text, "")

        api.mock(CreateAlertThreshold(userID: "1", value: nil, alertType: .courseAnnouncement), value: APIAlertThreshold.make(
            id: "4",
            user_id: "1",
            alert_type: .courseAnnouncement,
            threshold: nil
        ))
        let cAnnounce = try XCTUnwrap(controller.alertSwitches.first { $0.tag == 5 })
        cAnnounce.isOn = true
        cAnnounce.sendActions(for: .valueChanged)
        XCTAssertNotNil(controller.threshold(for: .courseAnnouncement))

        api.mock(CreateAlertThreshold(userID: "1", value: nil, alertType: .institutionAnnouncement), error: NSError.internalError())
        let iAnnounce = try XCTUnwrap(controller.alertSwitches.first { $0.tag == 6 })
        iAnnounce.isOn = true
        iAnnounce.sendActions(for: .valueChanged)
        XCTAssertEqual((router.presented as? UIAlertController)?.message, "Internal Error")
        XCTAssertEqual(iAnnounce.isOn, false)

        controller.scrollView.refreshControl?.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual(cGradeHigh.text, "")
        XCTAssertEqual(cGradeLow.text, "65")
        XCTAssertEqual(aMissing.isOn, true)
        XCTAssertEqual(aGradeHigh.text, "")
        XCTAssertEqual(aGradeLow.text, "")
        XCTAssertEqual(cAnnounce.isOn, false)
        XCTAssertEqual(iAnnounce.isOn, false)

        api.mock(RemoveAlertThreshold(thresholdID: controller.threshold(for: .courseGradeLow)!.id))
        cGradeLow.text = " "
        cGradeLow.sendActions(for: .editingDidEnd)
        XCTAssertEqual(controller.threshold(for: .courseGradeLow), nil)
        XCTAssertEqual(cGradeLow.text, "")

        XCTAssertNoThrow(controller.viewWillDisappear(false))
    }
}
