//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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
import XCTest
@testable import Core

class AccountListPresenterTests: CoreTestCase {
    class View: AccountListView {
        var onReload: (() -> Void)?
        func reload() {
            onReload?()
        }
    }

    let view = View()
    var presenter: AccountListPresenter!

    override func setUp() {
        super.setUp()
        presenter = AccountListPresenter(env: environment)
        presenter.view = view
    }

    func testReload() {
        api.mock(presenter.accounts, value: [.make()])
        let expectation = XCTestExpectation(description: "accounts loaded")
        view.onReload = {
            if self.presenter.accounts.count == 1 {
                expectation.fulfill()
            }
        }
        presenter.viewIsReady()
        wait(for: [expectation], timeout: 1)
    }
}
