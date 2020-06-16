//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

public protocol ColorDelegate: class {
    var iconColor: UIColor? { get }
}

public class GradeListViewController: UIViewController, ColoredNavViewProtocol {
    @IBOutlet weak var emptyMessageLabel: UILabel!
    @IBOutlet weak var emptyTitleLabel: UILabel!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var errorView: ListErrorView!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var gradingPeriodLabel: UILabel!
    @IBOutlet weak var gradingPeriodView: UIView!
    @IBOutlet weak var loadingView: CircleProgressView!
    @IBOutlet weak var tableView: UITableView!
    public let titleSubtitleView = TitleSubtitleView.create()
    @IBOutlet weak var totalGradeHeadingLabel: UILabel!
    @IBOutlet weak var totalGradeLabel: UILabel!
    let refreshControl = CircleRefreshControl()

    let env = AppEnvironment.shared
    public var color: UIColor?
    public weak var colorDelegate: ColorDelegate?
    var courseID = ""
    var courseEnrollment: Enrollment? {
        return courses.first?.enrollments?.first {
            $0.state == .active &&
            $0.userID == userID &&
            $0.type.lowercased().contains("student")
        }
    }
    var gradeEnrollment: Enrollment? {
        return enrollments.first {
            $0.id != nil &&
            $0.state == .active &&
            $0.userID == userID &&
            $0.type.lowercased().contains("student")
        }
    }
    public weak var gradeListCellIconDelegate: GradeListCellIconDelegate?
    var gradingPeriodID: String?
    var gradingPeriodLoaded = false
    var userID: String?

    lazy var assignments = env.subscribe(GetAssignmentsByGroup(courseID: courseID, gradingPeriodID: gradingPeriodID)) { [weak self] in
        self?.update()
    }
    lazy var colors = env.subscribe(GetCustomColors()) { [weak self] in
        self?.updateNavBar()
    }
    lazy var courses = env.subscribe(GetCourse(courseID: courseID)) { [weak self] in
        self?.updateNavBar()
        self?.update()
    }
    lazy var enrollments = env.subscribe(GetEnrollments(
        context: .course(courseID),
        userID: userID,
        gradingPeriodID: gradingPeriodID,
        types: [ "StudentEnrollment" ],
        states: [ .active ]
    )) { [weak self] in
        self?.update()
    }
    lazy var gradingPeriods = env.subscribe(GetGradingPeriods(courseID: courseID)) { [weak self] in
        self?.update()
    }

    public static func create(courseID: String, userID: String? = nil, colorDelegate: ColorDelegate? = nil) -> GradeListViewController {
        let controller = loadFromStoryboard()
        controller.colorDelegate = colorDelegate
        controller.courseID = courseID
        controller.userID = userID ?? controller.env.currentSession?.userID
        return controller
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupTitleViewInNavbar(title: NSLocalizedString("Grades", bundle: .core, comment: ""))
        view.backgroundColor = .named(.backgroundLightest)

        emptyMessageLabel.text = NSLocalizedString("It looks like assignments haven’t been created in this space yet.", bundle: .core, comment: "")
        emptyTitleLabel.text = NSLocalizedString("No Assignments", bundle: .core, comment: "")
        errorView.messageLabel.text = NSLocalizedString("There was an error loading grades. Pull to refresh to try again.", bundle: .core, comment: "")
        errorView.retryButton.addTarget(self, action: #selector(refresh), for: .primaryActionTriggered)
        filterButton.setTitle(NSLocalizedString("Filter", bundle: .core, comment: ""), for: .normal)

        gradingPeriodView.isHidden = true

        loadingView.color = nil
        refreshControl.color = nil

        refreshControl.addTarget(self, action: #selector(refresh), for: .primaryActionTriggered)
        tableView.refreshControl = refreshControl
        tableView.registerHeaderFooterView(SectionHeaderView.self)
        tableView.separatorColor = .named(.borderMedium)

        totalGradeHeadingLabel.text = NSLocalizedString("Total Grade", bundle: .core, comment: "")

        assignments.refresh()
        colors.refresh()
        courses.refresh()
        enrollments.refresh()
        gradingPeriods.refresh()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let index = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: index, animated: animated)
        }
        if let color = color {
            navigationController?.navigationBar.useContextColor(color)
        }
        env.pageViewLogger.startTrackingTimeOnViewController()
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        env.pageViewLogger.stopTrackingTimeOnViewController(eventName: "courses/\(courseID)/grades", attributes: [:])
    }

    @objc func refresh() {
        assignments.refresh(force: true) { [weak self] _ in
            self?.refreshControl.endRefreshing()
        }
        colors.refresh(force: true)
        courses.refresh(force: true)
        enrollments.refresh(force: true)
        gradingPeriods.refresh(force: true)
    }

    func updateNavBar() {
        guard let course = courses.first else { return }
        color = colorDelegate?.iconColor ?? course.color.ensureContrast(against: .named(.white))
        titleSubtitleView.subtitle = course.name
        navigationController?.navigationBar.useContextColor(color)
        view.tintColor = color
    }

    func update() {
        if !gradingPeriodLoaded, gradingPeriodID != courseEnrollment?.currentGradingPeriodID {
            updateGradingPeriod(id: courseEnrollment?.currentGradingPeriodID)
        }
        gradingPeriodLoaded = gradingPeriodLoaded || (courses.requested && !courses.pending)
        gradingPeriodView.isHidden = !gradingPeriodLoaded || courseEnrollment?.multipleGradingPeriodsEnabled == false
        gradingPeriodLabel.text = gradingPeriodID == nil && gradingPeriodLoaded
            ? NSLocalizedString("All Grading Periods", bundle: .core, comment: "")
            : gradingPeriods.first(where: { $0.id == gradingPeriodID })?.title

        if courses.first?.hideFinalGrades == true {
            totalGradeLabel.text = NSLocalizedString("N/A", bundle: .core, comment: "")
        } else if gradingPeriodID != nil, gradeEnrollment?.currentScore(gradingPeriodID: gradingPeriodID) != nil {
            totalGradeLabel.text = gradeEnrollment?.formattedCurrentScore(gradingPeriodID: gradingPeriodID)
        } else {
            totalGradeLabel.text = courseEnrollment?.formattedCurrentScore(gradingPeriodID: gradingPeriodID)
        }

        let isLoading = !assignments.requested || assignments.pending || !gradingPeriodLoaded
        loadingView.isHidden = assignments.error != nil || !isLoading || !assignments.isEmpty || refreshControl.isRefreshing
        emptyView.isHidden = assignments.error != nil || isLoading || !assignments.isEmpty
        errorView.isHidden = assignments.error == nil
        tableView.reloadData()
    }

    func updateGradingPeriod(id: String?) {
        gradingPeriodID = id
        enrollments = env.subscribe(GetEnrollments(
            context: .course(courseID),
            userID: userID,
            gradingPeriodID: gradingPeriodID,
            types: [ "StudentEnrollment" ],
            states: [ .active ]
        )) { [weak self] in
            self?.update()
        }
        assignments = env.subscribe(GetAssignmentsByGroup(courseID: courseID, gradingPeriodID: gradingPeriodID)) { [weak self] in
            self?.update()
        }
        // Delete assignment groups immediately, to see a spinner again
        assignments.useCase.reset(context: env.database.viewContext)
        try? env.database.viewContext.save()
        assignments.refresh(force: true)
        enrollments.refresh(force: true)
    }

    @IBAction func filter(_ sender: UIButton) {
        let alert = UIAlertController(title: nil, message: NSLocalizedString("Filter by:", bundle: .core, comment: ""), preferredStyle: .actionSheet)
        alert.addAction(AlertAction(NSLocalizedString("All Grading Periods", bundle: .core, comment: ""), style: .default) { [weak self] _ in
            self?.updateGradingPeriod(id: nil)
        })
        for period in gradingPeriods where period.title?.isEmpty == false {
            alert.addAction(AlertAction(period.title, style: .default) { [weak self] _ in
                self?.updateGradingPeriod(id: period.id)
            })
        }
        alert.addAction(AlertAction(NSLocalizedString("Cancel", bundle: .core, comment: ""), style: .cancel))
        alert.popoverPresentationController?.sourceView = sender
        alert.popoverPresentationController?.sourceRect = sender.bounds
        env.router.show(alert, from: self, options: .modal())
    }
}

extension GradeListViewController: UITableViewDataSource, UITableViewDelegate {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return assignments.sections?.count ?? 1
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = assignments.sections?[section].numberOfObjects ?? 0
        if assignments.hasNextPage, section + 1 == assignments.sections?.count {
            count += 1
        }
        return count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if assignments.hasNextPage && indexPath.row == assignments.sections?[indexPath.section].numberOfObjects {
            assignments.getNextPage()
            return LoadingCell(style: .default, reuseIdentifier: nil)
        }
        let assignment = assignments[indexPath]
        let cell: GradeListCell = tableView.dequeue(for: indexPath)
        cell.typeImage.image = gradeListCellIconDelegate?.iconImage(for: assignment) ?? assignment?.icon
        cell.update(assignment, userID: userID)
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let assignment = assignments[indexPath] else { return }
        env.router.route(to: .course(courseID, assignment: assignment.id), from: self, options: .detail)
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueHeaderFooter(SectionHeaderView.self)
        view.titleLabel?.text = assignments[IndexPath(row: 0, section: section)]?.assignmentGroup?.name
        return view
    }
}

public class GradeListCell: UITableViewCell {
    @IBOutlet weak var dueLabel: UILabel!
    @IBOutlet weak var gradeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var typeImage: UIImageView!

    func update(_ assignment: Assignment?, userID: String?) {
        let submission = assignment?.submissions?.first { $0.userID == userID }
        accessibilityIdentifier = "GradeListCell.\(assignment?.id ?? "")"
        nameLabel.text = assignment?.name
        gradeLabel.text = assignment.flatMap {
            GradeFormatter.string(from: $0, userID: userID, style: .medium)
        }
        dueLabel.text = assignment?.dueText
        statusLabel.isHidden = assignment?.isOnline != true
        let status = submission?.status ?? .notSubmitted
        statusLabel.text = status.text
        statusLabel.textColor = status.color
    }
}

public protocol GradeListCellIconDelegate: class {
    func iconImage(for assignment: Assignment?) -> UIImage?
}
