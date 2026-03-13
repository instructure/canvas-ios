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

@testable import Core
@testable import Student
import XCTest

final class LearnerDashboardSettingsWidgetsSectionVMTests: XCTestCase {

    private var testee: LearnerDashboardSettingsWidgetsSectionViewModel!
    private var userDefaults: SessionDefaults!
    private var onConfigsChangedCallCount = 0

    override func setUp() {
        super.setUp()
        userDefaults = SessionDefaults(sessionID: "test-session")
        userDefaults.reset()
        onConfigsChangedCallCount = 0
    }

    override func tearDown() {
        testee = nil
        userDefaults.reset()
        userDefaults = nil
        super.tearDown()
    }

    // MARK: - Initialization

    func test_init_splitsConfigsByVisibility() {
        let configs = [
            DashboardWidgetConfig.make(id: .helloWidget, order: 0, isVisible: true),
            DashboardWidgetConfig.make(id: .coursesAndGroups, order: 1, isVisible: false)
        ]

        testee = makeTestee(configs: configs)

        XCTAssertEqual(testee.visibleConfigs.count, 1)
        XCTAssertEqual(testee.visibleConfigs[0].id, .helloWidget)
        XCTAssertEqual(testee.hiddenConfigs.count, 1)
        XCTAssertEqual(testee.hiddenConfigs[0].id, .coursesAndGroups)
    }

    func test_init_visibleConfigsSortedByOrder() {
        let configs = [
            DashboardWidgetConfig.make(id: .coursesAndGroups, order: 0, isVisible: true),
            DashboardWidgetConfig.make(id: .helloWidget, order: 1, isVisible: true)
        ]

        testee = makeTestee(configs: configs)

        XCTAssertEqual(testee.visibleConfigs[0].id, .coursesAndGroups)
        XCTAssertEqual(testee.visibleConfigs[1].id, .helloWidget)
    }

    // MARK: - toggleVisibility

    func test_toggleVisibility_hidingVisibleWidget_movesToHidden() {
        let configs = [
            DashboardWidgetConfig.make(id: .helloWidget, order: 0, isVisible: true),
            DashboardWidgetConfig.make(id: .coursesAndGroups, order: 1, isVisible: true)
        ]
        testee = makeTestee(configs: configs)

        testee.toggleVisibility(of: testee.visibleConfigs[0], to: false)

        XCTAssertEqual(testee.visibleConfigs.count, 1)
        XCTAssertEqual(testee.hiddenConfigs.count, 1)
        XCTAssertEqual(testee.hiddenConfigs[0].id, .helloWidget)
    }

    func test_toggleVisibility_showingHiddenWidget_movesToVisible() {
        let configs = [
            DashboardWidgetConfig.make(id: .helloWidget, order: 0, isVisible: false),
            DashboardWidgetConfig.make(id: .coursesAndGroups, order: 1, isVisible: true)
        ]
        testee = makeTestee(configs: configs)

        testee.toggleVisibility(of: testee.hiddenConfigs[0], to: true)

        XCTAssertEqual(testee.visibleConfigs.count, 2)
        XCTAssertEqual(testee.hiddenConfigs.count, 0)
        XCTAssertTrue(testee.visibleConfigs.contains { $0.id == .helloWidget })
    }

    func test_toggleVisibility_hidingVisibleWidget_insertsAtTopOfHidden() {
        let configs = [
            DashboardWidgetConfig.make(id: .helloWidget, order: 0, isVisible: true),
            DashboardWidgetConfig.make(id: .coursesAndGroups, order: 1, isVisible: false)
        ]
        testee = makeTestee(configs: configs)

        testee.toggleVisibility(of: testee.visibleConfigs[0], to: false)

        XCTAssertEqual(testee.hiddenConfigs[0].id, .helloWidget)
        XCTAssertEqual(testee.hiddenConfigs[1].id, .coursesAndGroups)
    }

    func test_toggleVisibility_savesToDefaultsAndCallsCallback() {
        let configs = [
            DashboardWidgetConfig.make(id: .helloWidget, order: 0, isVisible: true),
            DashboardWidgetConfig.make(id: .coursesAndGroups, order: 1, isVisible: true)
        ]
        testee = makeTestee(configs: configs)

        testee.toggleVisibility(of: testee.visibleConfigs[0], to: false)

        XCTAssertNotNil(userDefaults.learnerDashboardWidgetConfigs)
        XCTAssertEqual(onConfigsChangedCallCount, 1)
    }

    // MARK: - moveUp

    func test_moveUp_swapsWithPreviousConfig() {
        let configs = [
            DashboardWidgetConfig.make(id: .helloWidget, order: 0, isVisible: true),
            DashboardWidgetConfig.make(id: .coursesAndGroups, order: 1, isVisible: true)
        ]
        testee = makeTestee(configs: configs)

        testee.moveUp(testee.visibleConfigs[1])

        XCTAssertEqual(testee.visibleConfigs[0].id, .coursesAndGroups)
        XCTAssertEqual(testee.visibleConfigs[1].id, .helloWidget)
    }

    func test_moveUp_firstElement_doesNothing() {
        let configs = [
            DashboardWidgetConfig.make(id: .helloWidget, order: 0, isVisible: true),
            DashboardWidgetConfig.make(id: .coursesAndGroups, order: 1, isVisible: true)
        ]
        testee = makeTestee(configs: configs)

        testee.moveUp(testee.visibleConfigs[0])

        XCTAssertEqual(testee.visibleConfigs[0].id, .helloWidget)
        XCTAssertEqual(testee.visibleConfigs[1].id, .coursesAndGroups)
        XCTAssertEqual(onConfigsChangedCallCount, 0)
    }

    // MARK: - moveDown

    func test_moveDown_swapsWithNextConfig() {
        let configs = [
            DashboardWidgetConfig.make(id: .helloWidget, order: 0, isVisible: true),
            DashboardWidgetConfig.make(id: .coursesAndGroups, order: 1, isVisible: true)
        ]
        testee = makeTestee(configs: configs)

        testee.moveDown(testee.visibleConfigs[0])

        XCTAssertEqual(testee.visibleConfigs[0].id, .coursesAndGroups)
        XCTAssertEqual(testee.visibleConfigs[1].id, .helloWidget)
    }

    func test_moveDown_lastElement_doesNothing() {
        let configs = [
            DashboardWidgetConfig.make(id: .helloWidget, order: 0, isVisible: true),
            DashboardWidgetConfig.make(id: .coursesAndGroups, order: 1, isVisible: true)
        ]
        testee = makeTestee(configs: configs)

        testee.moveDown(testee.visibleConfigs[1])

        XCTAssertEqual(testee.visibleConfigs[0].id, .helloWidget)
        XCTAssertEqual(testee.visibleConfigs[1].id, .coursesAndGroups)
        XCTAssertEqual(onConfigsChangedCallCount, 0)
    }

    // MARK: - isMoveUpDisabled

    func test_isMoveUpDisabled_trueForFirstElement() {
        let configs = [
            DashboardWidgetConfig.make(id: .helloWidget, order: 0, isVisible: true),
            DashboardWidgetConfig.make(id: .coursesAndGroups, order: 1, isVisible: true)
        ]
        testee = makeTestee(configs: configs)

        XCTAssertTrue(testee.isMoveUpDisabled(of: testee.visibleConfigs[0]))
    }

    func test_isMoveUpDisabled_falseForOtherElements() {
        let configs = [
            DashboardWidgetConfig.make(id: .helloWidget, order: 0, isVisible: true),
            DashboardWidgetConfig.make(id: .coursesAndGroups, order: 1, isVisible: true)
        ]
        testee = makeTestee(configs: configs)

        XCTAssertFalse(testee.isMoveUpDisabled(of: testee.visibleConfigs[1]))
    }

    // MARK: - isMoveDownDisabled

    func test_isMoveDownDisabled_trueForLastElement() {
        let configs = [
            DashboardWidgetConfig.make(id: .helloWidget, order: 0, isVisible: true),
            DashboardWidgetConfig.make(id: .coursesAndGroups, order: 1, isVisible: true)
        ]
        testee = makeTestee(configs: configs)

        XCTAssertTrue(testee.isMoveDownDisabled(of: testee.visibleConfigs[1]))
    }

    func test_isMoveDownDisabled_falseForOtherElements() {
        let configs = [
            DashboardWidgetConfig.make(id: .helloWidget, order: 0, isVisible: true),
            DashboardWidgetConfig.make(id: .coursesAndGroups, order: 1, isVisible: true)
        ]
        testee = makeTestee(configs: configs)

        XCTAssertFalse(testee.isMoveDownDisabled(of: testee.visibleConfigs[0]))
    }

    // MARK: - saveAndNotify

    func test_saveAndNotify_updatesOrderAndPersists() {
        let configs = [
            DashboardWidgetConfig.make(id: .helloWidget, order: 0, isVisible: true),
            DashboardWidgetConfig.make(id: .coursesAndGroups, order: 1, isVisible: true)
        ]
        testee = makeTestee(configs: configs)

        testee.moveDown(testee.visibleConfigs[0])

        let saved = userDefaults.learnerDashboardWidgetConfigs
        XCTAssertNotNil(saved)
        let coursesAndGroups = saved?.first { $0.id == .coursesAndGroups }
        let helloWidget = saved?.first { $0.id == .helloWidget }
        XCTAssertEqual(coursesAndGroups?.order, 0)
        XCTAssertEqual(helloWidget?.order, 1)
    }

    // MARK: - Private helpers

    private func makeTestee(configs: [DashboardWidgetConfig]) -> LearnerDashboardSettingsWidgetsSectionViewModel {
        LearnerDashboardSettingsWidgetsSectionViewModel(
            userDefaults: userDefaults,
            configs: configs,
            username: "Test User",
            onConfigsChanged: { [weak self] in self?.onConfigsChangedCallCount += 1 }
        )
    }
}
