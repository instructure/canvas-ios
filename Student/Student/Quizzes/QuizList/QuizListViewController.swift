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
import CoreData
import Core

class QuizListViewController: UIViewController, ColoredNavViewProtocol {
    @IBOutlet weak var emptyMessageLabel: UILabel!
    @IBOutlet weak var emptyTitleLabel: UILabel!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var errorView: ListErrorView!
    @IBOutlet weak var loadingView: CircleProgressView!
    @IBOutlet weak var tableView: UITableView!
    let refreshControl = CircleRefreshControl()
    var titleSubtitleView = TitleSubtitleView.create()

    var color: UIColor?
    var courseID = ""
    let env = AppEnvironment.shared

    lazy var colors = env.subscribe(GetCustomColors()) { [weak self] in
        self?.update()
    }
    lazy var course = env.subscribe(GetCourse(courseID: courseID)) { [weak self] in
        self?.update()
    }
    lazy var quizzes = env.subscribe(GetQuizzes(courseID: courseID)) { [weak self] in
        self?.update()
    }

    static func create(courseID: String) -> QuizListViewController {
        let controller = loadFromStoryboard()
        controller.courseID = courseID
        return controller
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTitleViewInNavbar(title: NSLocalizedString("Quizzes", comment: ""))

        emptyMessageLabel.text = NSLocalizedString("It looks like quizzes haven’t been created in this space yet.", comment: "")
        emptyTitleLabel.text = NSLocalizedString("No Quizzes", comment: "")
        errorView.messageLabel.text = NSLocalizedString("There was an error loading quizzes. Pull to refresh to try again.", comment: "")
        errorView.retryButton.addTarget(self, action: #selector(refresh), for: .primaryActionTriggered)

        loadingView.color = nil
        refreshControl.color = nil

        refreshControl.addTarget(self, action: #selector(refresh), for: .primaryActionTriggered)
        tableView.refreshControl = refreshControl
        tableView.separatorColor = .named(.borderMedium)

        colors.refresh()
        course.refresh()
        quizzes.exhaust()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.selectRow(at: nil, animated: false, scrollPosition: .none)
        env.pageViewLogger.startTrackingTimeOnViewController()
        if let color = color {
            navigationController?.navigationBar.useContextColor(color)
        }
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        env.pageViewLogger.stopTrackingTimeOnViewController(eventName: "courses/\(courseID)/quizzes", attributes: [:])
    }

    @objc func refresh() {
        colors.refresh(force: true)
        course.refresh(force: true)
        quizzes.exhaust(force: true) { [weak self] _ in
            if self?.quizzes.hasNextPage == false {
                self?.refreshControl.endRefreshing()
            }
            return true
        }
    }

    func update() {
        if let course = course.first, colors.pending == false {
            updateNavBar(subtitle: course.name, color: course.color)
            view.tintColor = course.color
        }
        let isLoading = !quizzes.requested || quizzes.pending
        loadingView.isHidden = quizzes.error != nil || !isLoading || !quizzes.isEmpty || refreshControl.isRefreshing
        emptyView.isHidden = quizzes.error != nil || isLoading || !quizzes.isEmpty
        errorView.isHidden = quizzes.error == nil
        tableView.reloadData()
    }
}

extension QuizListViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return quizzes.numberOfSections
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let typeRaw = quizzes.sections?[section].name, let type = QuizType(rawValue: typeRaw) else { return nil }
        return SectionHeaderView.create(title: type.sectionTitle, section: section)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quizzes.sections?[section].numberOfObjects ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: QuizListCell = tableView.dequeue(for: indexPath)
        cell.update(quiz: quizzes[indexPath])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let htmlURL = quizzes[indexPath]?.htmlURL else { return }
        env.router.route(to: htmlURL, from: self, options: .detail)
    }
}

class QuizListCell: UITableViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var questionsLabel: UILabel!
    @IBOutlet weak var statusDot: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!

    func update(quiz: Quiz?) {
        dateLabel.text = quiz?.dueText
        titleLabel.text = quiz?.title
        pointsLabel.text = quiz?.pointsPossibleText
        questionsLabel.text = quiz?.nQuestionsText
        if let statusText = quiz?.lockStatusText {
            statusLabel.text = statusText
            statusLabel.isHidden = false
            statusDot.isHidden = false
        } else {
            statusLabel.isHidden = true
            statusDot.isHidden = true
        }
    }
}
