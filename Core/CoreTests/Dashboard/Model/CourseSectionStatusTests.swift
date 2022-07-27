//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

class CourseSectionStatusTests: CoreTestCase {

    func testPendingFlagUpdates() {
        let testee = CourseSectionStatus()
        XCTAssertTrue(testee.isUpdatePending)

        let refreshExpectation = expectation(description: "completion block called")
        testee.refresh {
            refreshExpectation.fulfill()
        }

        wait(for: [refreshExpectation], timeout: 0.1)
        XCTAssertFalse(testee.isUpdatePending)
    }

    func testExpiredSection() {
        // Enrollments mock
        let enrollments: [APIEnrollment] = [
            .make(id: "1", course_id: "course_1", course_section_id: "section_1"),
        ]
        let request = GetEnrollmentsRequest(context: .currentUser, states: [.active])
        api.mock(request, value: enrollments)

        // Course mock
        let section = APICourse.SectionRef(end_at: .distantPast, id: "section_1", name: "", start_at: nil)
        let course = Course.make(from: .make(id: "course_1", sections: [section]))

        // DashboardCard mock
        let dashboardCard = DashboardCard.save(.make(id: "course_1"), position: 0, in: databaseClient)

        let testee = CourseSectionStatus()
        testee.refresh { }
        drainMainQueue()

        XCTAssertTrue(testee.isAllSectionsExpired(in: course))
        XCTAssertTrue(testee.isAllSectionsExpired(for: dashboardCard, in: [course]))

        let noSectionCourse = Course.make(from: .make(id: "course_2", sections: nil))
        XCTAssertFalse(testee.isAllSectionsExpired(in: noSectionCourse))
    }

    func testExpiredSectionAndActiveSectionWithoutEndDate() {
        // Enrollments mock
        let enrollments: [APIEnrollment] = [
            .make(id: "1", course_id: "course_1", course_section_id: "activeSection"),
            .make(id: "2", course_id: "course_1", course_section_id: "expiredSection"),
        ]
        let request = GetEnrollmentsRequest(context: .currentUser, states: [.active])
        api.mock(request, value: enrollments)

        // Course mock
        let activeSection = APICourse.SectionRef(end_at: nil, id: "activeSection", name: "", start_at: nil)
        let expiredSection = APICourse.SectionRef(end_at: .distantPast, id: "expiredSection", name: "", start_at: nil)
        let course = Course.make(from: .make(id: "course_1", sections: [activeSection, expiredSection]))

        // DashboardCard mock
        let dashboardCard = DashboardCard.save(.make(id: "course_1"), position: 0, in: databaseClient)

        let testee = CourseSectionStatus()
        testee.refresh { }
        drainMainQueue()

        XCTAssertFalse(testee.isAllSectionsExpired(in: course))
        XCTAssertFalse(testee.isAllSectionsExpired(for: dashboardCard, in: [course]))
    }

    func testExpiredSectionAndActiveSectionWithNonPastEndDate() {
        // Enrollments mock
        let enrollments: [APIEnrollment] = [
            .make(id: "1", course_id: "course_1", course_section_id: "activeSection"),
            .make(id: "2", course_id: "course_1", course_section_id: "expiredSection"),
        ]
        let request = GetEnrollmentsRequest(context: .currentUser, states: [.active])
        api.mock(request, value: enrollments)

        // Course mock
        let activeSection = APICourse.SectionRef(end_at: Clock.now.addDays(1), id: "activeSection", name: "", start_at: nil)
        let expiredSection = APICourse.SectionRef(end_at: .distantPast, id: "expiredSection", name: "", start_at: nil)
        let course = Course.make(from: .make(id: "course_1", sections: [activeSection, expiredSection]))

        // DashboardCard mock
        let dashboardCard = DashboardCard.save(.make(id: "course_1"), position: 0, in: databaseClient)

        let testee = CourseSectionStatus()
        testee.refresh { }
        drainMainQueue()

        XCTAssertFalse(testee.isAllSectionsExpired(in: course))
        XCTAssertFalse(testee.isAllSectionsExpired(for: dashboardCard, in: [course]))
    }

    func testSectionWithConcludedEnrollment() {
        // No active enrollments to be returned by mock
        let enrollments: [APIEnrollment] = []
        let request = GetEnrollmentsRequest(context: .currentUser, states: [.active])
        api.mock(request, value: enrollments)

        // Course mock
        let section = APICourse.SectionRef(end_at: nil, id: "", name: "", start_at: nil)
        let course = Course.make(from: .make(id: "course_1", sections: [section]))

        // DashboardCard mock
        let dashboardCard = DashboardCard.save(.make(id: "course_1"), position: 0, in: databaseClient)

        let testee = CourseSectionStatus()
        testee.refresh { }
        drainMainQueue()

        XCTAssertFalse(testee.isAllSectionsExpired(in: course))
        XCTAssertFalse(testee.isAllSectionsExpired(for: dashboardCard, in: [course]))
        XCTAssertTrue(testee.isNoActiveEnrollments(in: course))
    }
}
