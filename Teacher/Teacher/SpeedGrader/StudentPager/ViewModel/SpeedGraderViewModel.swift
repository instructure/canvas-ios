//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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
import Core
import SwiftUI

class SpeedGraderViewModel: ObservableObject, PagesViewControllerDataSource, PagesViewControllerDelegate {
    typealias Page = CoreHostingController<SubmissionGraderView>

    @Published var state: InstUI.ScreenState = .loading
    @Published var currentPage: UIViewController?

    // MARK: - Inputs
    let didTapDoneButton = PassthroughSubject<WeakViewController, Never>()
    let viewDidAppear = PassthroughSubject<Void, Never>()
    let didShowPagesViewController = PassthroughSubject<PagesViewController, Never>()

    // MARK: - Private

    private let interactor: SpeedGraderInteractor
    private let environment: AppEnvironment
    private var subscriptions = Set<AnyCancellable>()

    init(
        interactor: SpeedGraderInteractor,
        environment: AppEnvironment
    ) {
        self.interactor = interactor
        self.environment = environment
        subscribeToInteractorStateChanges()

        didTapDoneButton
            .sink { [router = environment.router] viewController in
                router.dismiss(viewController)
            }
            .store(in: &subscriptions)

        viewDidAppear
            .sink { [weak interactor] in
                interactor?.loadInitialData()
            }
            .store(in: &subscriptions)

        didShowPagesViewController
            .sink { [weak self] pages in
                self?.updatePages(pages)
            }
            .store(in: &subscriptions)
    }

    // MARK: - PagesViewControllerDataSource

    func pagesViewController(_ pages: PagesViewController, pageBefore page: UIViewController) -> UIViewController? {
        (page as? Page).flatMap { controller(for: $0.rootView.content.userIndexInSubmissionList - 1) }
    }

    func pagesViewController(_ pages: PagesViewController, pageAfter page: UIViewController) -> UIViewController? {
        (page as? Page).flatMap { controller(for: $0.rootView.content.userIndexInSubmissionList + 1) }
    }

    func controller(for index: Int) -> UIViewController? {
        let controller = grader(for: index).map { CoreHostingController($0, env: environment) }
        controller?.view.backgroundColor = nil
        return controller
    }

    func grader(for index: Int) -> SubmissionGraderView? {
        guard
            let data = interactor.data,
            index >= 0,
            index < data.submissions.count
        else { return nil }

        return SubmissionGraderView(
            env: environment,
            userIndexInSubmissionList: index,
            viewModel: SubmissionGraderViewModel(
                assignment: data.assignment,
                submission: data.submissions[index]
            ),
            handleRefresh: { [weak self] in
                self?.interactor.refreshSubmission(forUserId: data.submissions[index].userID)
            }
        )
    }

    private func updatePages(_ pages: PagesViewController) {
        guard let data = interactor.data else { return }

        if let page = controller(for: data.focusedSubmissionIndex) {
            pages.setCurrentPage(page)
        }

        for page in pages.children.compactMap({ $0 as? Page }) {
            if let grader = grader(for: page.rootView.content.userIndexInSubmissionList) {
                page.rootView.content = grader
            }
        }
    }

    // MARK: - State Subscription

    private func subscribeToInteractorStateChanges() {
        interactor
            .state
            .map { state in
                switch state {
                case .loading: return .loading
                case .data: return .data(loadingOverlay: false)
                case .error: return .empty
                }
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &$state)
    }
}
