//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import XCTest
@testable import Student

class DashboardIntegrationTests: XCTestCase {
    
    func testView() {
        let view = DashboardViewController.create()
        let mockPresenter = MockDashboardPresenter()
        view.presenter = mockPresenter
        
        XCTAssertNotNil(view.presenter)
        //XCTAssert(view.presenter! === mockPresenter)
        XCTAssert(view.viewModel == nil)
        
        view.loadViewIfNeeded()
        XCTAssert(mockPresenter.vcDidLoadMethodCalledCount == 1)
    }
    
    func testPresenter() {
        let mockView = MockDashboardView()
        let presenter = DashboardPresenter(view: mockView)
        
        XCTAssert(presenter.view === mockView)
        
        presenter.viewIsReady()
        XCTAssert(mockView.updateDisplayMethodCalledCount == 1)
        
        presenter.refreshRequested()
        XCTAssert(mockView.updateDisplayMethodCalledCount == 2)
    }
}
