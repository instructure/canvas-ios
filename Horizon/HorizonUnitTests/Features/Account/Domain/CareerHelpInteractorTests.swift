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

import Combine
@testable import Core
@testable import Horizon
import XCTest

final class CareerHelpInteractorTests: HorizonTestCase {
    private var testee: CareerHelpInteractorLive!

    override func setUp() {
        super.setUp()
        testee = CareerHelpInteractorLive()
    }

    override func tearDown() {
        testee = nil
        super.tearDown()
    }

    func testGetAccountHelpLinksReturnsEmptyWhenNoData() {
        mockEmptyHelpLinks()

        XCTAssertSingleOutputAndFinish(testee.getAccountHelpLinks(ignoreCache: false)) { models in
            XCTAssertEqual(models.count, 0)
        }
    }

    func testGetAccountHelpLinksReturnsSingleItem() {
        mockSingleHelpLink()

        XCTAssertSingleOutputAndFinish(testee.getAccountHelpLinks(ignoreCache: false)) { models in
            XCTAssertEqual(models.count, 1)
            XCTAssertEqual(models.first?.id, "training_services_portal")
            XCTAssertEqual(models.first?.title, "Training Services")
            XCTAssertEqual(models.first?.isBugReport, false)
        }
    }

    func testGetAccountHelpLinksReturnsMultipleItems() {
        mockMultipleHelpLinks()

        XCTAssertSingleOutputAndFinish(testee.getAccountHelpLinks(ignoreCache: false)) { models in
            XCTAssertEqual(models.count, 3)
        }
    }

    func testGetAccountHelpLinksSortsBugReportsFirst() {
        mockMultipleHelpLinks()

        XCTAssertSingleOutputAndFinish(testee.getAccountHelpLinks(ignoreCache: false)) { models in
            XCTAssertEqual(models.count, 3)
            XCTAssertEqual(models.first?.id, "report_a_problem")
            XCTAssertTrue(models.first?.isBugReport ?? false)
            XCTAssertFalse(models.last?.isBugReport ?? true)
        }
    }

    func testGetAccountHelpLinksIgnoresCache() {
        mockSingleHelpLink()

        XCTAssertSingleOutputAndFinish(testee.getAccountHelpLinks(ignoreCache: true)) { models in
            XCTAssertEqual(models.count, 1)
        }
    }

    func testGetAccountHelpLinksHandlesErrorGracefully() {
        api.mock(
            GetCareerHelpRequest(),
            error: NSError.instructureError("Test error")
        )

        XCTAssertSingleOutputAndFinish(testee.getAccountHelpLinks(ignoreCache: false)) { models in
            XCTAssertEqual(models.count, 0)
        }
    }

    func testGetAccountHelpLinksMapsToBugReportCorrectly() {
        mockBugReportHelpLink()

        XCTAssertSingleOutputAndFinish(testee.getAccountHelpLinks(ignoreCache: false)) { models in
            XCTAssertEqual(models.count, 1)
            let bugReport = models.first
            XCTAssertEqual(bugReport?.id, "report_a_problem")
            XCTAssertEqual(bugReport?.title, "Report a Problem")
            XCTAssertTrue(bugReport?.isBugReport ?? false)
            XCTAssertNil(bugReport?.url)
        }
    }

    func testGetAccountHelpLinksMapsToExternalLinkCorrectly() {
        mockExternalLinkHelpLink()

        XCTAssertSingleOutputAndFinish(testee.getAccountHelpLinks(ignoreCache: false)) { models in
            XCTAssertEqual(models.count, 1)
            let externalLink = models.first
            XCTAssertEqual(externalLink?.id, "training_services_portal")
            XCTAssertEqual(externalLink?.title, "Training Services")
            XCTAssertFalse(externalLink?.isBugReport ?? true)
            XCTAssertNotNil(externalLink?.url)
            XCTAssertEqual(externalLink?.url?.absoluteString, "https://example.com/training")
        }
    }

    private func mockEmptyHelpLinks() {
        let response: [GetCareerHelpResponse] = []
        api.mock(GetCareerHelpRequest(), value: response)
    }

    private func mockSingleHelpLink() {
        let response = [
            GetCareerHelpResponse.make(
                id: "training_services_portal",
                text: "Training Services",
                type: "link",
                url: URL(string: "https://example.com/training")
            )
        ]
        api.mock(GetCareerHelpRequest(), value: response)
    }

    private func mockMultipleHelpLinks() {
        let response = [
            GetCareerHelpResponse.make(
                id: "training_services_portal",
                text: "Training Services",
                type: "link",
                url: URL(string: "https://example.com/training")
            ),
            GetCareerHelpResponse.make(
                id: "custom_help",
                text: "Custom Help",
                type: "custom",
                url: URL(string: "https://example.com/custom")
            ),
            GetCareerHelpResponse.make(
                id: "report_a_problem",
                text: "Report a Problem",
                type: "bug",
                url: nil
            )
        ]
        api.mock(GetCareerHelpRequest(), value: response)
    }

    private func mockBugReportHelpLink() {
        let response = [
            GetCareerHelpResponse.make(
                id: "report_a_problem",
                text: "Report a Problem",
                type: "bug",
                url: nil
            )
        ]
        api.mock(GetCareerHelpRequest(), value: response)
    }

    private func mockExternalLinkHelpLink() {
        let response = [
            GetCareerHelpResponse.make(
                id: "training_services_portal",
                text: "Training Services",
                type: "link",
                url: URL(string: "https://example.com/training")
            )
        ]
        api.mock(GetCareerHelpRequest(), value: response)
    }
}
