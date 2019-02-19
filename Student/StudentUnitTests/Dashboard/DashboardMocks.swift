//
// Copyright (C) 2018-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation
@testable import Student
@testable import Core

class MockDashboardView: DashboardViewProtocol, ErrorViewController {
    var navigationController: UINavigationController?
    var updateDisplayMethodCalledCount = 0
    var showErrorMethodCalledCount = 0

    var presenter: DashboardPresenterProtocol?
    var viewModel: DashboardViewModel?

    func updateNavBar(logoUrl: URL, color: UIColor, backgroundColor: UIColor) {
    }

    func updateDisplay(_ viewModel: DashboardViewModel) {
        updateDisplayMethodCalledCount += 1

        self.viewModel = viewModel
    }

    func showError(_ error: Error) {
        showErrorMethodCalledCount += 1
    }

    func showError(_ error: NSError) {
        showErrorMethodCalledCount += 1
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
