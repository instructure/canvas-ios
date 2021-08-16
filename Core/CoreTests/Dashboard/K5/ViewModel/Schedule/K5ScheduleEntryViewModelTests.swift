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

import XCTest
@testable import Core

class K5ScheduleEntryViewModelTests: CoreTestCase {
    private lazy var mockAPIService = PlannerOverrideUpdater(api: api, plannable: .make())

    func testIsTappableFlag() {
        XCTAssertTrue(K5ScheduleEntryViewModel(leading: .warning,
                                               icon: .addAudioLine,
                                               title: "",
                                               subtitle: nil,
                                               labels: [], score: nil,
                                               dueText: "",
                                               route: URL(string: "/a")!,
                                               apiService: mockAPIService).isTappable)
        XCTAssertFalse(K5ScheduleEntryViewModel(leading: .warning,
                                                icon: .addAudioLine,
                                                title: "", subtitle: nil,
                                                labels: [],
                                                score: nil,
                                                dueText: "",
                                                route: nil,
                                                apiService: mockAPIService).isTappable)
    }

    func testRoutesModally() {
        router.routeExpectation = expectation(description: "Route happened")
        let subtitle = K5ScheduleEntryViewModel.SubtitleViewModel(text: "", color: .black, font: .bold11)
        let labels = [K5ScheduleEntryViewModel.LabelViewModel(text: "", color: .black)]
        let testee = K5ScheduleEntryViewModel(leading: .warning,
                                              icon: .addAudioLine,
                                              title: "",
                                              subtitle: subtitle,
                                              labels: labels,
                                              score: nil,
                                              dueText: "",
                                              route: URL(string: "/a")!,
                                              apiService: mockAPIService)

        testee.itemTapped(router: router, viewController: WeakViewController(UIViewController()))

        wait(for: [router.routeExpectation], timeout: 0.1)
        XCTAssertTrue(router.lastRoutedTo("/a", withOptions: .modal(isDismissable: false, embedInNav: true, addDoneButton: true)))
    }

    func testLeadingSetterTriggersChangeEvent() {
        let refreshTriggeredExpectation = expectation(description: "Refresh expectation")
        let testee = K5ScheduleEntryViewModel(leading: .checkbox(isChecked: false),
                                              icon: .addAudioLine,
                                              title: "",
                                              subtitle: nil,
                                              labels: [],
                                              score: nil,
                                              dueText: "",
                                              route: nil,
                                              apiService: mockAPIService)
        let subscription = testee.objectWillChange.sink {
            refreshTriggeredExpectation.fulfill()
        }

        testee.leading = .checkbox(isChecked: true)

        wait(for: [refreshTriggeredExpectation], timeout: 0.1)
        subscription.cancel()
    }
}
