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

@testable import Core
import XCTest

class TabFilterTests: CoreTestCase {

    func testStudentHiddenFilter() {
        let assignmentsTab: Tab = databaseClient.insert()
        assignmentsTab.position = 3
        assignmentsTab.hidden = false

        let pagesTab: Tab = databaseClient.insert()
        pagesTab.position = 1
        pagesTab.hidden = true

        let filesTab: Tab = databaseClient.insert()
        filesTab.position = 2
        filesTab.hidden = false

        XCTAssertEqual([assignmentsTab, pagesTab, filesTab].filteredTabsForCourseHome(isStudent: true), [filesTab, assignmentsTab])
    }

    func testTeacherExternalToolHiddenFilter() {
        let LTI1Tab: Tab = databaseClient.insert()
        LTI1Tab.position = 3
        LTI1Tab.hidden = false
        LTI1Tab.id = "1external_tool1"

        let LTI2Tab: Tab = databaseClient.insert()
        LTI2Tab.position = 1
        LTI2Tab.hidden = true
        LTI2Tab.id = "2external_tool2"

        let LTI3Tab: Tab = databaseClient.insert()
        LTI3Tab.position = 2
        LTI3Tab.hidden = false
        LTI3Tab.id = "3external_tool3"

        XCTAssertEqual([LTI1Tab, LTI2Tab, LTI3Tab].filteredTabsForCourseHome(isStudent: false), [LTI3Tab, LTI1Tab])
    }

    func testTeacherMobileSupportedTabsFilter() {
        let assignmentsTab: Tab = databaseClient.insert()
        assignmentsTab.position = 0
        assignmentsTab.hidden = true
        assignmentsTab.id = TabName.assignments.rawValue

        let quizzesTab: Tab = databaseClient.insert()
        quizzesTab.position = 1
        quizzesTab.hidden = true
        quizzesTab.id = TabName.quizzes.rawValue

        let discussionsTab: Tab = databaseClient.insert()
        discussionsTab.position = 2
        discussionsTab.hidden = true
        discussionsTab.id = TabName.discussions.rawValue

        let announcementsTab: Tab = databaseClient.insert()
        announcementsTab.position = 3
        announcementsTab.hidden = true
        announcementsTab.id = TabName.announcements.rawValue

        let peopleTab: Tab = databaseClient.insert()
        peopleTab.position = 4
        peopleTab.hidden = true
        peopleTab.id = TabName.people.rawValue

        let pagesTab: Tab = databaseClient.insert()
        pagesTab.position = 5
        pagesTab.hidden = true
        pagesTab.id = TabName.pages.rawValue

        let filesTab: Tab = databaseClient.insert()
        filesTab.position = 6
        filesTab.hidden = true
        filesTab.id = TabName.files.rawValue

        let modulesTab: Tab = databaseClient.insert()
        modulesTab.position = 8
        modulesTab.hidden = true
        modulesTab.id = TabName.modules.rawValue

        let syllabusTab: Tab = databaseClient.insert()
        syllabusTab.position = 7
        syllabusTab.hidden = true
        syllabusTab.id = TabName.syllabus.rawValue

        let collaborationsTab: Tab = databaseClient.insert()
        collaborationsTab.position = 9
        collaborationsTab.hidden = true
        collaborationsTab.id = TabName.collaborations.rawValue

        let conferencesTab: Tab = databaseClient.insert()
        conferencesTab.position = 10
        conferencesTab.hidden = true
        conferencesTab.id = TabName.conferences.rawValue

        let outcomesTab: Tab = databaseClient.insert()
        outcomesTab.position = 11
        outcomesTab.hidden = true
        outcomesTab.id = TabName.outcomes.rawValue

        let customTab: Tab = databaseClient.insert()
        customTab.position = 12
        customTab.hidden = true
        customTab.id = TabName.custom.rawValue

        let allTabs: [Tab] = [
            assignmentsTab, quizzesTab, discussionsTab, announcementsTab, peopleTab, pagesTab, filesTab, modulesTab, syllabusTab,
            collaborationsTab, conferencesTab, outcomesTab, customTab
        ]
        XCTAssertEqual(allTabs.filteredTabsForCourseHome(isStudent: false), [assignmentsTab, quizzesTab, discussionsTab, announcementsTab, peopleTab, pagesTab, filesTab, syllabusTab, modulesTab])
    }
}
