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

import Combine
@testable import Core
import TestsFoundation

final class ModulePublishProgressViewModelTests: CoreTestCase {

    func testTitle() {
        var testee = makeViewModel(action: .publish(.modulesAndItems), allModules: true)
        XCTAssertEqual(testee.title, .allModulesAndItems)
        testee = makeViewModel(action: .unpublish(.modulesAndItems), allModules: true)
        XCTAssertEqual(testee.title, .allModulesAndItems)

        testee = makeViewModel(action: .publish(.onlyModules), allModules: true)
        XCTAssertEqual(testee.title, .allModules)
        testee = makeViewModel(action: .unpublish(.onlyModules), allModules: true)
        XCTAssertEqual(testee.title, .allModules)

        testee = makeViewModel(action: .publish(.modulesAndItems), allModules: false)
        XCTAssertEqual(testee.title, .selectedModuleAndItems)
        testee = makeViewModel(action: .unpublish(.modulesAndItems), allModules: false)
        XCTAssertEqual(testee.title, .selectedModuleAndItems)

        testee = makeViewModel(action: .publish(.onlyModules), allModules: false)
        XCTAssertEqual(testee.title, .selectedModule)
        testee = makeViewModel(action: .unpublish(.onlyModules), allModules: false)
        XCTAssertEqual(testee.title, .selectedModule)
    }

    func testIsPublish() {
        var action: ModulePublishAction

        action = .publish
        var testee = makeViewModel(action: action)
        XCTAssertEqual(testee.isPublish, action.isPublish)

        action = .unpublish
        testee = makeViewModel(action: action)
        XCTAssertEqual(testee.isPublish, action.isPublish)
    }

    func testDidTapDismiss() {
        let vc = UIViewController()
        let testee = makeViewModel()

        testee.didTapDismiss.send(.init(vc))

        XCTAssertEqual(router.dismissed, vc)
    }

    func testDidTapCancel() {
        let vc = SnackBarProviderMock()
        let testee = makeViewModel()

        testee.didTapCancel.send((.init(vc), "some snack"))

        XCTAssertEqual(router.dismissed, vc)
        XCTAssertEqual(vc.snackBarViewModel.visibleSnack, "some snack")
    }

    func testDidTapDone() {
        let vc = UIViewController()
        let testee = makeViewModel()

        testee.didTapDone.send(.init(vc))

        XCTAssertEqual(router.dismissed, vc)
    }
}

private extension ModulePublishProgressViewModelTests {
    func makeViewModel(
        action: ModulePublishAction = .publish(.onlyModules),
        allModules: Bool = false
    ) -> ModulePublishProgressViewModel {
        .init(action: action, allModules: allModules, router: router)
    }

    final class SnackBarProviderMock: UIViewController, SnackBarProvider {
        var snackBarViewModel = SnackBarViewModel()
    }
}
