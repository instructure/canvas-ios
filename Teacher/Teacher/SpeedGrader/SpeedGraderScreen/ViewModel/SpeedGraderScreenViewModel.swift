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

class SpeedGraderScreenViewModel: ObservableObject {
    typealias Page = CoreHostingController<SpeedGraderPageView>

    // MARK: - Outputs

    @Published private(set) var state: InstUI.ScreenState = .loading
    @Published private(set) var currentPage: UIViewController?
    @Published private(set) var isPostPolicyButtonVisible = false
    @Published private(set) var navigationTitle = ""
    @Published private(set) var navigationSubtitle = ""
    @Published private(set) var navigationBarColor = Brand.shared.navBackground
    public let screenViewTrackingParameters: ScreenViewTrackingParameters

    // MARK: - Inputs

    let didTapDoneButton = PassthroughSubject<WeakViewController, Never>()
    let didTapPostPolicyButton = PassthroughSubject<WeakViewController, Never>()
    let didShowPagesViewController = PassthroughSubject<PagesViewController, Never>()

    // MARK: - Private

    private let interactor: SpeedGraderInteractor
    private let landscapeSplitLayoutViewModel = SpeedGraderLandscapeSplitLayoutViewModel()
    private let environment: AppEnvironment
    private var subscriptions = Set<AnyCancellable>()

    init(
        interactor: SpeedGraderInteractor,
        environment: AppEnvironment
    ) {
        self.interactor = interactor
        self.environment = environment
        screenViewTrackingParameters = ScreenViewTrackingParameters(
            eventName: "/\(interactor.context.pathComponent)/gradebook/speed_grader?assignment_id=\(interactor.assignmentID)&student_id=\(interactor.userID)"
        )

        showFocusedSubmission(on: didShowPagesViewController)
        showPostPolicyScreen(on: didTapPostPolicyButton)
        dismissScreen(on: didTapDoneButton)

        updateState(onChangeOf: interactor.state)
        updatePostPolicyButtonVisibility(onChangeOf: interactor.state)
        updateNavigationBarTheme(onChangeOf: interactor.contextInfo)

        // Start each session with a fresh state
        environment.userDefaults?.isSpeedGraderAnnotationToolbarVisible = true

        interactor.load()
    }

    // MARK: - State Subscription

    private func updateState(
        onChangeOf subject: CurrentValueSubject<SpeedGraderInteractorState, Never>
    ) {
        subject
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

    // MARK: - Private Methods

    private func updateNavigationBarTheme(
        onChangeOf subject: CurrentValueSubject<SpeedGraderContextInfo?, Never>
    ) {
        subject
            .compactMap { $0 }
            .sink { [weak self] contextInfo in
                self?.navigationTitle = contextInfo.assignmentName
                self?.navigationSubtitle = contextInfo.courseName
                self?.navigationBarColor = UIColor(contextInfo.courseColor)
            }
            .store(in: &subscriptions)
    }

    private func updatePostPolicyButtonVisibility(
        onChangeOf subject: CurrentValueSubject<SpeedGraderInteractorState, Never>
    ) {
        subject
            .map { $0 == .data }
            .assign(to: &$isPostPolicyButtonVisible)
    }

    private func dismissScreen(
        on subject: PassthroughSubject<WeakViewController, Never>
    ) {
        didTapDoneButton
            .sink { [router = environment.router] viewController in
                router.dismiss(viewController)
            }
            .store(in: &subscriptions)
    }

    private func showPostPolicyScreen(
        on subject: PassthroughSubject<WeakViewController, Never>
    ) {
        let context = interactor.context.pathComponent
        let assignmentID = interactor.assignmentID

        didTapPostPolicyButton
            .sink { [environment] viewController in
                environment.router.route(
                    to: "/\(context)/assignments/\(assignmentID)/post_policy",
                    from: viewController,
                    options: .modal(embedInNav: true, addDoneButton: true)
                )
            }
            .store(in: &subscriptions)
    }

    private func showFocusedSubmission(
        on subject: PassthroughSubject<PagesViewController, Never>
    ) {
        subject
            .sink { [weak self] pages in
                self?.updatePages(pages)
            }
            .store(in: &subscriptions)
    }
}

// MARK: - PagesViewControllerDataSource

extension SpeedGraderScreenViewModel: PagesViewControllerDataSource {

    func pagesViewController(
        _ pages: PagesViewController,
        pageBefore page: UIViewController
    ) -> UIViewController? {
        (page as? Page).flatMap { controller(for: $0.rootView.content.userIndexInSubmissionList - 1) }
    }

    func pagesViewController(
        _ pages: PagesViewController,
        pageAfter page: UIViewController
    ) -> UIViewController? {
        (page as? Page).flatMap { controller(for: $0.rootView.content.userIndexInSubmissionList + 1) }
    }

    private func controller(for index: Int) -> UIViewController? {
        let controller = grader(for: index).map { CoreHostingController($0, env: environment) }
        controller?.view.backgroundColor = nil
        return controller
    }

    private func grader(for index: Int) -> SpeedGraderPageView? {
        guard
            let data = interactor.data,
            data.submissions.indices.contains(index)
        else { return nil }

        return SpeedGraderPageView(
            env: environment,
            userIndexInSubmissionList: index,
            viewModel: SpeedGraderPageViewModel(
                assignment: data.assignment,
                latestSubmission: data.submissions[index],
                contextColor: interactor.contextInfo.compactMap { $0?.courseColor }.eraseToAnyPublisher(),
                gradeStatusInteractor: interactor.gradeStatusInteractor,
                env: environment
            ),
            landscapeSplitLayoutViewModel: landscapeSplitLayoutViewModel,
            handleRefresh: { [weak self] in
                guard let self else { return }
                interactor
                    .refreshSubmission(forUserId: data.submissions[index].userID)
                    .sink()
                    .store(in: &subscriptions)
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
}

// MARK: - PagesViewControllerDelegate

extension SpeedGraderScreenViewModel: PagesViewControllerDelegate {

    func pagesViewController(
        _ pages: PagesViewController,
        didTransitionTo page: UIViewController
    ) {
        pages.pauseWebViewPlayback()
        pages.pauseMediaPlayback()
    }
}
