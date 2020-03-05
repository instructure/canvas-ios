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

import Foundation
import UIKit

public class PlannerFilterViewController: UIViewController, ErrorViewController {
    @IBOutlet weak var headerLabel: DynamicLabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyStateView: UIView!
    @IBOutlet weak var emptyStateHeader: UILabel!
    @IBOutlet weak var emptyStateSubHeader: UILabel!
    @IBOutlet weak var errorView: ListErrorView!
    @IBOutlet weak var spinnerView: UIView!

    let env = AppEnvironment.shared
    var studentID: String?

    lazy var planners: Store<LocalUseCase<Planner>> = env.subscribe(scope: .where(#keyPath(Planner.studentID), equals: studentID)) { [weak self] in
        self?.update()
    }
    var planner: Planner? { planners.first }

    lazy var courses = env.subscribe(GetPlannerCourses(studentID: studentID)) { [weak self] in
        self?.update()
    }

    public static func create(studentID: String?) -> PlannerFilterViewController {
        let controller = loadFromStoryboard()
        controller.studentID = studentID
        return controller
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = NSLocalizedString("Calendars", bundle: .core, comment: "")

        let refresh = CircleRefreshControl()
        refresh.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        tableView.refreshControl = refresh
        tableView.registerHeaderFooterView(SectionHeaderView.self)
        headerLabel.text = NSLocalizedString("Tap to select the courses you want to see on the calendar.", bundle: .core, comment: "")

        emptyStateHeader.text = NSLocalizedString("No Courses", bundle: .core, comment: "")
        emptyStateSubHeader.text = NSLocalizedString("Your child's courses might not be published yet.", bundle: .core, comment: "")
        errorView.messageLabel.text = NSLocalizedString("There was an error loading courses. Pull to refresh to try again.", bundle: .core, comment: "")
        errorView.retryButton.addTarget(self, action: #selector(refresh(_:)), for: .primaryActionTriggered)
        emptyStateView.isHidden = true
        errorView.isHidden = true

        planners.refresh()
        courses.refresh(force: true) // TODO: store next page info in cache and don't force
    }

    func update() {
        guard courses.requested, courses.pending == false else { return }
        tableView.refreshControl?.endRefreshing()
        spinnerView.isHidden = true
        emptyStateView.isHidden = courses.error != nil || !courses.isEmpty
        errorView.isHidden = courses.error == nil
        tableView.reloadData()
    }

    @objc func refresh(_ control: CircleRefreshControl) {
        courses.refresh(force: true)
    }

    func toggleCourse(_ course: Course) throws {
        if planner?.selectedCourses.contains(course) == true {
            planner?.selectedCourses.remove(course)
        } else {
            planner?.selectedCourses.insert(course)
        }
        try env.database.viewContext.save()
    }
}

extension PlannerFilterViewController: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = courses.count
        if courses.hasNextPage {
            count += 1
        }
        return count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if courses.hasNextPage && indexPath.row == courses.count {
            courses.getNextPage()
            return LoadingCell(style: .default, reuseIdentifier: nil)
        }
        let cell = tableView.dequeue(for: indexPath) as PlannerFilterCell
        let course = courses[indexPath]
        cell.courseNameLabel.text = course?.courseCode
        cell.isChecked = course.flatMap { planner?.selectedCourses.contains($0) } ?? false
        return cell
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section == 0 else { return nil }
        let header = tableView.dequeueHeaderFooter(SectionHeaderView.self)
        header.titleLabel?.text = NSLocalizedString("Courses", bundle: .core, comment: "")
        return header
    }
}

extension PlannerFilterViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let course = courses[indexPath] else { return }
        do {
            try toggleCourse(course)
        } catch {
            showError(error)
        }
    }
}

class PlannerFilterCell: UITableViewCell {
    @IBOutlet weak var checkboxView: UIView!
    @IBOutlet weak var courseNameLabel: UILabel!
    @IBOutlet weak var checkmark: UIImageView!

    var isChecked: Bool = false {
        didSet {
            checkboxView.layer.borderWidth = isChecked ? 0 : 1
            checkmark.isHidden = !isChecked
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        checkboxView.backgroundColor = .clear
        checkboxView.layer.cornerRadius = 3
        checkboxView.layer.borderWidth = 1
        checkboxView.layer.borderColor = UIColor.named(.borderDark).cgColor
        checkmark.tintColor = .named(.backgroundInfo)
        selectionStyle = .none
    }
}
