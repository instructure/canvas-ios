//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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
import SwiftUI
import UIKit
import Core

class SpeedGraderViewController: ScreenViewTrackableViewController, PagesViewControllerDataSource {
    typealias Page = CoreHostingController<SubmissionGraderView>

    var env: AppEnvironment = .defaultValue

    lazy var screenViewTrackingParameters = ScreenViewTrackingParameters(
        eventName: "/\(interactor.context.pathComponent)/gradebook/speed_grader?assignment_id=\(interactor.assignmentID)&student_id=\(interactor.userID)"
    )

    internal let interactor: SpeedGraderInteractor
    private var subscriptions = Set<AnyCancellable>()
    lazy var pages = PagesViewController()

    init(env: AppEnvironment, interactor: SpeedGraderInteractor) {
        self.env = env
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
        subscribeToInteractorStateChanges()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundLightest
        embed(loadingView, in: view)
        interactor.load()
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if traitCollection.verticalSizeClass == .compact || traitCollection.horizontalSizeClass == .compact {
            return .portrait
        }
        return super.supportedInterfaceOrientations
    }

    // MARK: - Private Methods

    private func subscribeToInteractorStateChanges() {
        interactor.state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                switch state {
                case .loading: break
                case .data:
                    self?.showGradingView()
                case .error:
                    self?.showEmptyView()
                }
            }
            .store(in: &subscriptions)
    }

    private func showEmptyView() {
        loadingView.unembed()
        embed(emptyView, in: view)
        hideNavigationBar()
    }

    private func showGradingView() {
        guard let data = interactor.data else { return }
        loadingView.unembed()
        emptyView.unembed()
        pages.dataSource = self
        pages.scrollView.contentInsetAdjustmentBehavior = .never
        pages.scrollView.backgroundColor = .backgroundMedium
        if let page = controller(for: data.focusedSubmissionIndex) {
            pages.setCurrentPage(page)
        }
        embed(pages, in: view) { pages, view in
            pages.view.pin(inside: view, top: nil, bottom: nil)
            pages.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            pages.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        }
        updatePages()
        hideNavigationBar()
    }

    private func hideNavigationBar() {
        // SpeedGrader is by design not embedded into a navigation controller.
        // However, when navigating to this screen from CoreWebView's link handler
        // it automatically wraps it into a navigation controller and adds a Done button.
        // To avoid displaying double Close/Done buttons and an extra navigation bar hide it.
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    private lazy var loadingView: UIViewController = CoreHostingController(
        ProgressView()
            .progressViewStyle(.indeterminateCircle())
            .accessibility(label: Text("Loading", bundle: .teacher))
            .identifier("SpeedGrader.spinner"),
        env: env
    )

    internal lazy var emptyView: UIViewController = CoreHostingController(
        VStack {
            HStack {
                Spacer()
                Button("Close") { [weak self] in
                    guard let self = self else { return }
                    self.env.router.dismiss(self)
                }
                    .font(.semibold16).accentColor(Color(Brand.shared.linkColor))
                    .padding(16)
                    .identifier("SpeedGrader.emptyCloseButton")
            }
            EmptyPanda(.Space,
                title: Text("No Submissions", bundle: .teacher),
                message: Text("It seems there aren't any valid submissions to grade.", bundle: .teacher)
            )
        }
    )

    private func updatePages() {
        for page in pages.children.compactMap({ $0 as? Page }) {
            if let grader = grader(for: page.rootView.content.userIndexInSubmissionList) {
                page.rootView.content = grader
            }
        }
    }

    // MARK: - PagesViewControllerDataSource

    func pagesViewController(_ pages: PagesViewController, pageBefore page: UIViewController) -> UIViewController? {
        (page as? Page).flatMap { controller(for: $0.rootView.content.userIndexInSubmissionList - 1) }
    }

    func pagesViewController(_ pages: PagesViewController, pageAfter page: UIViewController) -> UIViewController? {
        (page as? Page).flatMap { controller(for: $0.rootView.content.userIndexInSubmissionList + 1) }
    }

    func controller(for index: Int) -> UIViewController? {
        let controller = grader(for: index).map { CoreHostingController($0, env: env) }
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
            env: env,
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

    /// Helper function to help normalize user ids coming from webview urls
    static func normalizeUserID(_ userID: String?) -> String {
        if let userID, userID.containsOnlyNumbers {
            return userID
        }

        return SpeedGraderAllUsersUserID
    }
}
