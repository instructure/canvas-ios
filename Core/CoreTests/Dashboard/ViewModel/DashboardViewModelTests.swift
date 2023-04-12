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

import Core
import Combine
import XCTest

class DashboardViewModelTests: CoreTestCase {
    private var subscriptions = Set<AnyCancellable>()

    func testCreatesSettingsView() {
        // MARK: - GIVEN
        let viewShownExpectation = expectation(description: "Settings was created")
        let testee = DashboardContainerViewModel(environment: environment)
        testee.showSettings
            .sink { (view: UIViewController, _) in
                defer { viewShownExpectation.fulfill() }

                guard let settings = (view as? HelmNavigationController)?.viewControllers.first,
                      settings is CoreHostingController<DashboardSettingsView>
                else {
                    return XCTFail()
                }
            }
            .store(in: &subscriptions)

        // MARK: - WHEN
        testee.settingsButtonTapped.send()

        // MARK: - THEN
        waitForExpectations(timeout: 1)
    }
}
