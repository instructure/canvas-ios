//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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

import UIKit
import Core

protocol QuizListViewProtocol: ErrorViewController, ColoredNavViewProtocol {
    func update(isLoading: Bool)
}

class QuizListViewController: UIViewController, QuizListViewProtocol {
    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var loadingView: CircleProgressView!
    @IBOutlet weak var tableView: UITableView!
    let refreshControl = CircleRefreshControl()

    var color: UIColor?
    var presenter: QuizListPresenter?
    var titleSubtitleView: TitleSubtitleView = TitleSubtitleView.create()

    static func create(env: AppEnvironment = .shared, courseID: String) -> QuizListViewController {
        let view = loadFromStoryboard()
        view.presenter = QuizListPresenter(env: env, view: view, courseID: courseID)
        return view
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTitleViewInNavbar(title: NSLocalizedString("Quizzes", bundle: .student, comment: ""))

        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        tableView?.refreshControl = refreshControl
        tableView?.separatorColor = .named(.borderMedium)

        presenter?.viewIsReady()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView?.selectRow(at: nil, animated: false, scrollPosition: .none)
        presenter?.viewDidAppear()
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter?.viewDidDisappear()
    }

    @objc func refresh(_ control: CircleRefreshControl) {
        presenter?.quizzes.refresh(force: true)
    }

    func update(isLoading: Bool) {
        tableView?.reloadData()
        if let color = color {
            loadingView.color = color
            refreshControl.color = color
        }
        let isEmpty = presenter?.quizzes.isEmpty == true
        if isEmpty && !isLoading {
            emptyLabel?.text = NSLocalizedString("There are no quizzes to display.", bundle: .student, comment: "")
            emptyLabel?.textColor = .named(.textDarkest)
            emptyLabel?.isHidden = false
        } else {
            emptyLabel?.isHidden = true
        }
        if !isEmpty || !isLoading {
            loadingView.isHidden = true
            refreshControl.endRefreshing()
        }
    }

    func showError(_ error: Error) {
        emptyLabel?.text = NSLocalizedString("Something went wrong while loading the quizzes.", bundle: .student, comment: "")
        emptyLabel?.textColor = .named(.textDanger)
        emptyLabel?.isHidden = false
    }
}

extension QuizListViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return presenter?.quizzes.numberOfSections ?? 0
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let title = presenter?.sectionTitle(section) else { return nil }
        return SectionHeaderView.create(title: title, section: section)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.section(section)?.numberOfObjects ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(QuizListCell.self, for: indexPath)
        cell.update(quiz: presenter?.quiz(indexPath), color: color)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let quiz = presenter?.quiz(indexPath) else { return }
        presenter?.select(quiz, from: self)
    }
}

extension QuizListViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isBottomReached() {
            presenter?.quizzes.getNextPage()
        }
    }
}
