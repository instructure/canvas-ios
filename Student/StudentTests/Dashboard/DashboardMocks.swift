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

import Foundation
@testable import Student

class MockDashboardView: DashboardViewProtocol {
    var updateDisplayMethodCalledCount = 0
    
    var presenter: DashboardPresenterProtocol?
    var viewModel: DashboardViewModel?
    
    func updateDisplay(_ viewModel: DashboardViewModel) {
        updateDisplayMethodCalledCount += 1
        
        self.viewModel = viewModel
    }
}

class MockDashboardPresenter: DashboardPresenterProtocol {
    var loadDataMethodCalledCount = 0
    var courseWasSelectedMethodCalledCount = 0
    var editButtonWasTappedMethodCalledCount = 0
    var courseOptionsWasSelectedMethodCalledCount = 0
    var groupWasSelectedMethodCalledCount = 0
    var seellAllWasTappedMethodCalledCount = 0
    var vcDidLoadMethodCalledCount = 0
    var vcWillAppearMethodCalledCount = 0
    var vcWillDisappearMethodCalledCount = 0
    var refreshMethodCalledCount = 0
    
    weak var view: DashboardViewProtocol?
    
    func courseWasSelected(_ courseID: String) {
        courseWasSelectedMethodCalledCount += 1
    }
    
    func editButtonWasTapped() {
        editButtonWasTappedMethodCalledCount += 1
    }
    
    func viewIsReady() {
        vcDidLoadMethodCalledCount += 1
    }
    
    func loadData() {
        loadDataMethodCalledCount += 1
    }
    
    func pageViewStarted() {
        vcWillAppearMethodCalledCount += 1
    }
    
    func pageViewEnded() {
        vcWillDisappearMethodCalledCount += 1
    }

    func courseOptionsWasSelected(_ courseID: String) {
        courseOptionsWasSelectedMethodCalledCount += 1
    }
    
    func groupWasSelected(_ groupID: String) {
        groupWasSelectedMethodCalledCount += 1
    }
    
    func seeAllWasTapped() {
        seellAllWasTappedMethodCalledCount += 1
    }
    
    func refreshRequested() {
        refreshMethodCalledCount += 1
    }
}
