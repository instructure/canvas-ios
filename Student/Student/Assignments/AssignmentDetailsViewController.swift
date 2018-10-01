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

import Core
import UIKit

protocol AssignmentDetailsViewProtocol: ErrorViewController {
    func updateNavBar(subtitle: String, backgroundColor: UIColor)
    func update(assignment: AssignmentDetailsViewModel)
}

class AssignmentDetailsViewController: UIViewController, AssignmentDetailsViewProtocol {
    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var pointsLabel: UILabel?
    @IBOutlet weak var dueHeadingLabel: UILabel?
    @IBOutlet weak var dueLabel: UILabel?
    @IBOutlet weak var submissionTypesHeadingLabel: UILabel?
    @IBOutlet weak var submissionTypesLabel: UILabel?
    @IBOutlet weak var gradeHeadingLabel: UILabel?
    @IBOutlet weak var descriptionHeadingLabel: UILabel?
    @IBOutlet weak var scrollView: UIScrollView!
    var refreshControl: UIRefreshControl?
    let titleSubtitleView = TitleSubtitleView.create()
    var presenter: AssignmentDetailsPresenter?

    static func create(env: AppEnvironment = .shared, courseID: String, assignmentID: String) -> AssignmentDetailsViewController {
        let view = Bundle.loadController(self)
        view.presenter = AssignmentDetailsPresenter(env: env, view: view, courseID: courseID, assignmentID: assignmentID)
        return view
    }

    // MARK: Lifecycle methods

    override func viewDidLoad() {
        super.viewDidLoad()

        configurePullToRefresh()

        // Navigation Bar
        navigationItem.titleView = titleSubtitleView
        titleSubtitleView.title = NSLocalizedString("Assignment Details", bundle: .student, comment: "")

        // Localization
        dueHeadingLabel?.text = NSLocalizedString("Due", bundle: .student, comment: "")
        submissionTypesHeadingLabel?.text = NSLocalizedString("Submission Types", bundle: .student, comment: "")
        gradeHeadingLabel?.text = NSLocalizedString("Grade", bundle: .student, comment: "")
        descriptionHeadingLabel?.text = NSLocalizedString("Description", bundle: .student, comment: "")

        presenter?.viewIsReady()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter?.pageViewStarted()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter?.pageViewEnded()
    }

    func configurePullToRefresh() {
        scrollView.alwaysBounceVertical = true
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(actionHandleRefresh(_:)), for: UIControl.Event.valueChanged)
        guard let refreshControl = refreshControl else { return }
        scrollView.addSubview(refreshControl)
    }

    @objc func actionHandleRefresh(_ refreshControl: UIRefreshControl) {
        presenter?.loadDataFromServer()
    }

    func updateNavBar(subtitle: String, backgroundColor: UIColor) {
        titleSubtitleView.subtitle = subtitle
        navigationController?.navigationBar.tintColor = .named(.white)
        navigationController?.navigationBar.barTintColor = backgroundColor.ensureContrast(against: .named(.white))
        navigationController?.navigationBar.barStyle = .black
    }

    func update(assignment: AssignmentDetailsViewModel) {
        nameLabel?.text = assignment.name
        pointsLabel?.text = assignment.pointsPossibleText
        dueLabel?.text = assignment.dueText
        submissionTypesLabel?.text = assignment.submissionTypeText
        refreshControl?.endRefreshing()
    }

    func showError(_ error: Error) {
        // TODO
    }
}
