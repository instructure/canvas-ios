//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

import Core
import XCTest

class GetGlobalNavExternalToolsPlacementsTests: XCTestCase {

    func testAllowedGlobalLTIDomains() {
        XCTAssertEqual(HelpLinkEnrollment.observer.allowedGlobalLTIDomains,
                       [.masteryConnect])
        XCTAssertEqual(HelpLinkEnrollment.admin.allowedGlobalLTIDomains,
                       [.studio, .gauge, .masteryConnect, .eportfolio])
        XCTAssertEqual(HelpLinkEnrollment.student.allowedGlobalLTIDomains,
                       [.studio, .gauge, .masteryConnect, .eportfolio])
        XCTAssertEqual(HelpLinkEnrollment.teacher.allowedGlobalLTIDomains,
                       [.studio, .gauge, .masteryConnect, .eportfolio])
        XCTAssertEqual(HelpLinkEnrollment.unenrolled.allowedGlobalLTIDomains,
                       [.studio, .gauge])
        XCTAssertEqual(HelpLinkEnrollment.user.allowedGlobalLTIDomains,
                       [.studio, .gauge])
    }

    func test_scope() throws {
        try checkPredicateForLinkEnrollment(.admin)
        try checkPredicateForLinkEnrollment(.observer)
        try checkPredicateForLinkEnrollment(.student)
        try checkPredicateForLinkEnrollment(.teacher)
        try checkPredicateForLinkEnrollment(.unenrolled)
        try checkPredicateForLinkEnrollment(.user)
    }

    private func checkPredicateForLinkEnrollment(_ link: HelpLinkEnrollment) throws {
        let locationPart = NSPredicate(
            format: "%K == %@",
            #keyPath(ExternalToolLaunchPlacement.locationRaw),
            ExternalToolLaunchPlacementLocation.global_navigation.rawValue
        )

        let predicate = try XCTUnwrap(GetGlobalNavExternalToolsPlacements(enrollment: link).scope.predicate as? NSCompoundPredicate)

        XCTAssertEqual(predicate.compoundPredicateType, .and)
        XCTAssertEqual(predicate.subpredicates.first as? NSPredicate, locationPart)

        let domainPredicate = try XCTUnwrap(predicate.subpredicates.last as? NSCompoundPredicate)
        XCTAssertEqual(domainPredicate.compoundPredicateType, .or)

        let expectedDomainPredicates = link.allowedGlobalLTIDomains.map { domain in
            let format = domain == .eportfolio ? "%K CONTAINS[c] %@" : "%K == %@"
            return NSPredicate(format: format, #keyPath(ExternalToolLaunchPlacement.domain), domain.rawValue)
        }

        XCTAssertEqual(domainPredicate.subpredicates as? [NSPredicate], expectedDomainPredicates)
    }
}
