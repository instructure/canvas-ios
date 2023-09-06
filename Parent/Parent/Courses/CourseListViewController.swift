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

import UIKit
import Core

class CourseListViewController: UIViewController {
    @IBOutlet weak var emptyMessageLabel: UILabel!
    @IBOutlet weak var emptyTitleLabel: UILabel!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var errorView: ListErrorView!
    let refreshControl = CircleRefreshControl()
    @IBOutlet weak var spinnerView: CircleProgressView!
    @IBOutlet weak var tableView: UITableView!

    let env = AppEnvironment.shared
    var studentID = ""

    lazy var courses = env.subscribe(GetUserCourses(userID: studentID)) { [weak self] in
        self?.update()
    }

    static func create(studentID: String) -> CourseListViewController {
        let controller = loadFromStoryboard()
        controller.studentID = studentID
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundLightest

        emptyMessageLabel.text = NSLocalizedString("Your child’s courses might not be published yet.", comment: "")
        emptyTitleLabel.text = NSLocalizedString("No Courses", comment: "")
        errorView.messageLabel.text = NSLocalizedString("There was an error loading courses. Pull to refresh to try again.", comment: "")
        errorView.retryButton.addTarget(self, action: #selector(refresh), for: .primaryActionTriggered)

        spinnerView.color = nil
        tableView.backgroundColor = .backgroundLightest
        refreshControl.addTarget(self, action: #selector(refresh), for: .primaryActionTriggered)
        refreshControl.color = nil
        tableView.refreshControl = refreshControl
        tableView.separatorColor = .borderMedium
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let selected = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selected, animated: true)
        }

        courses.exhaust()
    }

    func update() {
        spinnerView.isHidden = !courses.pending || !courses.isEmpty || courses.error != nil || refreshControl.isRefreshing
        emptyView.isHidden = courses.pending || !courses.isEmpty || courses.error != nil
        errorView.isHidden = courses.error == nil
        tableView.reloadData()
    }

    @objc func refresh() {
        courses.exhaust(force: true) { [weak self] _ in
            if self?.courses.hasNextPage == false {
                self?.refreshControl.endRefreshing()
            }
            return true
        }
    }
}

extension CourseListViewController: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courses.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(CourseListCell.self, for: indexPath)
        cell.update(courses[indexPath], studentID: studentID)
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let course = courses[indexPath] else { return }
        env.router.route(to: "/courses/\(course.id)/grades", from: self, options: .detail)
    }
}

class CourseListCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var gradeLabel: UILabel!

    func update(_ course: Course?, studentID: String) {
        backgroundColor = .backgroundLightest
        let id = course?.id ?? ""
        accessibilityIdentifier = "course_cell_\(id)"

        nameLabel.accessibilityIdentifier = "course_title_\(id)"
        nameLabel.setText(course?.name, style: .textCellTitle)

        codeLabel.accessibilityIdentifier = "course_code_\(id)"
        codeLabel.setText(course?.courseCode, style: .textCellSupportingTextBold)

        gradeLabel.accessibilityIdentifier = "course_grade_\(id)"
        gradeLabel.setText(displayGrade(course, studentID: studentID), style: .textCellBottomLabel)
    }

    func displayGrade(_ course: Course?, studentID: String) -> String {
        guard let course = course, let enrollment = course.enrollments?.first(where: { $0.userID == studentID && $0.isStudent }) else {
            return ""
        }

        if course.hideTotalGrade {
            // this condition also triggers when multipleGradingPeriodsEnabled is true, currentGradingPeriodID is nil and totalsForAllGradingPeriodsOption is false
            return course.hideFinalGrades ? "" : NSLocalizedString("N/A", comment: "")
        }

        var grade = enrollment.computedCurrentGrade
        var score = enrollment.computedCurrentScore

        if enrollment.multipleGradingPeriodsEnabled {
            if enrollment.currentGradingPeriodID != nil {
                grade = enrollment.currentPeriodComputedCurrentGrade
                score = enrollment.currentPeriodComputedCurrentScore
            } else if enrollment.totalsForAllGradingPeriodsOption {
                grade = enrollment.computedCurrentGrade
                score = enrollment.computedCurrentScore
            }
        }

        if course.hideQuantitativeData == true {
            if let grade {
                return grade
            } else if let score {
                return enrollment.convertedLetterGrade(gradingPeriodID: enrollment.currentGradingPeriodID,
                                                       gradingScheme: course.gradingScheme)
            } else {
                return NSLocalizedString("No Grade", comment: "")
            }
        }

        guard let scoreNoNil = score, let scoreString = Course.scoreFormatter.string(from: NSNumber(value: scoreNoNil)) else {
            return grade ?? NSLocalizedString("No Grade", comment: "")
        }

        if let grade = grade {
            return "\(grade)   \(scoreString)"
        }
        return scoreString
    }
}
