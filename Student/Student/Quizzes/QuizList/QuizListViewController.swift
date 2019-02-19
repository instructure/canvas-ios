//
// Copyright (C) 2016-present Instructure, Inc.
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

import UIKit
import Core

protocol QuizListItemModel: DueViewable, GradeViewable, QuestionCountViewable, LockStatusViewable {
    var htmlURL: URL { get }
    var title: String { get }
}

protocol QuizListViewProtocol: ErrorViewController, ColoredNavViewProtocol {
    func update(isLoading: Bool)
}

class QuizListViewController: UITableViewController, QuizListViewProtocol {
    var emptyView: UIView?
    var presenter: QuizListPresenter?
    let loadingView = UIActivityIndicatorView(style: .gray)
    var titleSubtitleView: TitleSubtitleView = TitleSubtitleView.create()

    var color: UIColor?
    var hasAppeared = false

    static func create(env: AppEnvironment = .shared, courseID: String) -> QuizListViewController {
        let view = Bundle.loadController(self)
        view.presenter = QuizListPresenter(env: env, view: view, courseID: courseID)
        view.emptyView = Bundle.loadView(QuizListEmptyView.self)
        return view
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTitleViewInNavbar(title: NSLocalizedString("Quizzes", bundle: .student, comment: ""))

        refreshControl?.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)

        loadingView.color = Brand.shared.primary.ensureContrast(against: .named(.white))
        tableView.backgroundView = loadingView
        loadingView.startAnimating()

        presenter?.viewIsReady()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter?.pageViewStarted()
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter?.pageViewEnded()
    }

    @objc func refresh(_ control: UIRefreshControl) {
        presenter?.quizzes.refresh(force: true)
    }

    func update(isLoading: Bool) {
        guard isViewLoaded else { return }
        tableView.backgroundView = presenter?.quizzes.count == 0 ? (isLoading ? loadingView : emptyView) : nil
        tableView.reloadData()
        refreshControl?.endRefreshing()
    }

    func showError(_ error: Error) {
        let errorView = Bundle.loadView(QuizListEmptyView.self)
        errorView.label?.text = NSLocalizedString("Something went wrong while loading the quizzes.", bundle: .student, comment: "")
        errorView.label?.textColor = .named(.textDanger)
        tableView.backgroundView = errorView
        // TODO: log error to analytics
    }

    func quizAt(_ indexPath: IndexPath) -> QuizListItemModel? {
        return presenter?.quizzes[indexPath]
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.quizzes.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(QuizListCell.self, for: indexPath)
        cell.update(quiz: quizAt(indexPath), color: color)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let quiz = quizAt(indexPath) else { return }
        presenter?.select(quiz, from: self)
    }
}
