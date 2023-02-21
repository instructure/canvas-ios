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

import SwiftUI
import UIKit
import Core

class SpeedGraderViewController: ScreenViewTrackableViewController, PagesViewControllerDataSource {
    typealias Page = CoreHostingController<SubmissionGrader>

    let assignmentID: String
    let context: Context
    let env = AppEnvironment.shared
    let filter: [GetSubmissions.Filter]
    var initialIndex: Int?
    let userID: String?

    var keepIDs: [String] = []
    lazy var screenViewTrackingParameters = ScreenViewTrackingParameters(
        eventName: "/\(context.pathComponent)/gradebook/speed_grader?assignment_id=\(assignmentID)&student_id=\(userID ?? "")"
    )
    lazy var assignment = env.subscribe(GetAssignment(courseID: context.id, assignmentID: assignmentID, include: [ .overrides ])) { [weak self] in
        self?.update()
    }
    lazy var submissions = env.subscribe(GetSubmissions(context: context, assignmentID: assignmentID, filter: filter)) { [weak self] in
        self?.update()
    }

    init(context: Context, assignmentID: String, userID: String, filter: [GetSubmissions.Filter]) {
        self.assignmentID = assignmentID
        self.context = context
        self.filter = filter
        self.userID = userID == "speedgrader" ? nil : userID
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundLightest
        embed(loadingView, in: view)
        assignment.refresh()
        submissions.exhaust()
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if traitCollection.verticalSizeClass == .compact || traitCollection.horizontalSizeClass == .compact {
            return .portrait
        }
        return super.supportedInterfaceOrientations
    }

    func update() {
        guard assignment.requested && !assignment.pending && submissions.requested && !submissions.pending && !submissions.hasNextPage else { return }

        if !submissions.useCase.shuffled, assignment.first?.anonymizeStudents == true {
            submissions.useCase.shuffled = true
            submissions.setScope(submissions.useCase.scope)
        }

        // Make sure a submission can't disappear as it gets graded.
        let ids = submissions.map { $0.userID }
        if keepIDs != ids {
            keepIDs = ids
            submissions.setScope(submissions.useCase.scopeKeepingIDs(ids))
        }

        if initialIndex == nil, let current = findCurrentIndex() {
            initialIndex = current
            loadingView.unembed()
            emptyView.unembed()
            pages.dataSource = self
            pages.scrollView.contentInsetAdjustmentBehavior = .never
            pages.scrollView.backgroundColor = .backgroundMedium
            if let page = controller(for: current) {
                pages.setCurrentPage(page)
            }
            embed(pages, in: view) { pages, view in
                pages.view.pin(inside: view, top: nil, bottom: nil)
                pages.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
                pages.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
            }
        }

        if initialIndex == nil, !isLoading, emptyView.parent == nil {
            loadingView.unembed()
            embed(emptyView, in: view)
        }

        updatePages()
    }

    var isLoading: Bool {
        !assignment.requested || assignment.pending ||
        !submissions.requested || submissions.pending || submissions.hasNextPage
    }

    func findCurrentIndex() -> Int? {
        guard !isLoading, assignment.first?.anonymizeStudents == submissions.useCase.shuffled else { return nil }
        return submissions.all.firstIndex { userID == nil || $0.userID == userID }
    }

    lazy var loadingView: UIViewController = CoreHostingController(
        ProgressView()
            .progressViewStyle(.indeterminateCircle())
            .accessibility(label: Text("Loading"))
            .identifier("SpeedGrader.spinner")
    )

    lazy var emptyView: UIViewController = CoreHostingController(
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
                title: Text("No Submissions"),
                message: Text("It seems there aren't any valid submissions to grade.")
            )
        }
    )

    lazy var pages = PagesViewController()

    func pagesViewController(_ pages: PagesViewController, pageBefore page: UIViewController) -> UIViewController? {
        (page as? Page).flatMap { controller(for: $0.rootView.content.index - 1) }
    }

    func pagesViewController(_ pages: PagesViewController, pageAfter page: UIViewController) -> UIViewController? {
        (page as? Page).flatMap { controller(for: $0.rootView.content.index + 1) }
    }

    func controller(for index: Int) -> UIViewController? {
        let controller = grader(for: index).map { CoreHostingController($0) }
        controller?.view.backgroundColor = nil
        return controller
    }

    func grader(for index: Int) -> SubmissionGrader? {
        guard index >= 0, index < submissions.all.count, let assignment = assignment.first else { return nil }
        return SubmissionGrader(
            index: index,
            assignment: assignment,
            submission: submissions.all[index],
            handleRefresh: { [weak self] in
                self?.submissions.refresh(force: true)
            }
        )
    }

    func updatePages() {
        for page in pages.children.compactMap({ $0 as? Page }) {
            if let grader = grader(for: page.rootView.content.index) {
                page.rootView.content = grader
            }
        }
    }
}
