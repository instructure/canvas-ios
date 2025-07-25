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

public class QuizListViewController: ScreenViewTrackableViewController, ColoredNavViewProtocol {
    @IBOutlet weak var emptyMessageLabel: UILabel!
    @IBOutlet weak var emptyTitleLabel: UILabel!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var errorView: ListErrorView!
    @IBOutlet weak var loadingView: CircleProgressView!
    @IBOutlet weak var tableView: UITableView!
    let refreshControl = CircleRefreshControl()
    public var titleSubtitleView = TitleSubtitleView.create()

    public var color: UIColor?
    var courseID = ""
    private(set) var env: AppEnvironment = .shared
    var selectedFirstQuiz: Bool = false
    public lazy var screenViewTrackingParameters = ScreenViewTrackingParameters(
        eventName: "courses/\(courseID)/quizzes"
    )

    lazy var colors = env.subscribe(GetCustomColors()) { [weak self] in
        self?.update()
    }
    lazy var course = env.subscribe(GetCourse(courseID: courseID)) { [weak self] in
        self?.update()
    }
    lazy var quizzes = env.subscribe(GetQuizzes(courseID: courseID.localID)) { [weak self] in
        self?.update()
    }

    public static func create(courseID: String, env: AppEnvironment) -> QuizListViewController {
        let controller = loadFromStoryboard()
        controller.courseID = courseID
        controller.env = env
        return controller
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupTitleViewInNavbar(title: String(localized: "Quizzes", bundle: .core))

        emptyMessageLabel.text = String(localized: "It looks like quizzes haven’t been created in this space yet.", bundle: .core)
        emptyTitleLabel.text = String(localized: "No Quizzes", bundle: .core)
        errorView.messageLabel.text = String(localized: "There was an error loading quizzes. Pull to refresh to try again.", bundle: .core)
        errorView.retryButton.addTarget(self, action: #selector(refresh), for: .primaryActionTriggered)

        loadingView.color = nil
        refreshControl.color = nil

        refreshControl.addTarget(self, action: #selector(refresh), for: .primaryActionTriggered)
        tableView.refreshControl = refreshControl
        tableView.separatorColor = .borderMedium
        tableView.backgroundColor = .backgroundLightest
        view.backgroundColor = .backgroundLightest

        colors.refresh()
        course.refresh()
        quizzes.exhaust()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.selectRow(at: nil, animated: false, scrollPosition: .none)
        navigationController?.navigationBar.useContextColor(color)
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
        loadingView.isHidden = quizzes.state != .loading || refreshControl.isRefreshing
        emptyView.isHidden = quizzes.state != .empty
        errorView.isHidden = quizzes.state != .error
        tableView.reloadData()

        if !selectedFirstQuiz, quizzes.state != .loading, let url = quizzes.first?.htmlURL {
            selectedFirstQuiz = true
            if splitViewController?.isCollapsed == false, !isInSplitViewDetail {
                env.router.route(to: url, from: self, options: .detail)
            }
        }
    }
}

extension QuizListViewController: UITableViewDataSource, UITableViewDelegate {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return quizzes.numberOfSections
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let typeRaw = quizzes.sections?[section].name, let type = QuizType(rawValue: typeRaw) else { return nil }
        return SectionHeaderView.create(title: type.sectionTitle, section: section)
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quizzes.sections?[section].numberOfObjects ?? 0
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: QuizListCell = tableView.dequeue(for: indexPath)
        cell.update(quiz: quizzes[indexPath], isTeacher: course.first?.hasTeacherEnrollment == true, color: color)
        cell.accessibilityIdentifier = "QuizListCell.\(indexPath.section).\(indexPath.row)"
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let htmlURL = quizzes[indexPath]?.htmlURL else { return }
        env.router.route(to: htmlURL, from: self, options: .detail)
    }
}

class QuizListCell: UITableViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var iconImageView: AccessIconView!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var pointsDot: UILabel!
    @IBOutlet weak var questionsLabel: UILabel!
    @IBOutlet weak var statusDot: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        statusDot.setText(statusDot.text, style: .textCellSupportingText)
        pointsDot.setText(pointsDot.text, style: .textCellBottomLabel)
        setupInstDisclosureIndicator()
    }

    func update(quiz: Quiz?, isTeacher: Bool, color: UIColor?) {
        backgroundColor = .backgroundLightest
        selectedBackgroundView = ContextCellBackgroundView.create(color: color)
        if isTeacher {
            iconImageView.published = quiz?.published == true
        } else {
            iconImageView.state = nil
        }

        // title
        titleLabel.setText(quiz?.title, style: .textCellTitle)
        titleLabel.accessibilityIdentifier = "titleLabel"

        // status + date
        if let statusText = quiz?.lockStatusText {
            statusLabel.setText(statusText, style: .textCellSupportingText)
            statusLabel.accessibilityIdentifier = "statusLabel"
            statusLabel.isHidden = false
            statusDot.isHidden = false
        } else {
            statusLabel.isHidden = true
            statusDot.isHidden = true
        }
        dateLabel.setText(quiz?.dueText, style: .textCellSupportingText)
        dateLabel.accessibilityIdentifier = "dateLabel"

        // points + question count
        pointsLabel.setText(quiz?.pointsPossibleText, style: .textCellBottomLabel)
        pointsLabel.accessibilityIdentifier = "pointsLabel"
        pointsLabel.isHidden = quiz?.hideQuantitativeData == true
        let nQuestionsText = quiz?.nQuestionsText
        questionsLabel.setText(nQuestionsText, style: .textCellBottomLabel)
        questionsLabel.accessibilityIdentifier = "questionsLabel"
        questionsLabel.isHidden = nQuestionsText == nil
        pointsDot.isHidden = pointsLabel.isHidden || questionsLabel.isHidden
    }
}
