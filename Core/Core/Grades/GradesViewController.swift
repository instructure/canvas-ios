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
import CoreData

public protocol ColorDelegate: class {
    var iconColor: UIColor? { get }
}

public class GradesViewController: UIViewController {
    @IBOutlet weak var filterButton: DynamicButton!
    @IBOutlet weak var totalGradeLabel: DynamicLabel!
    @IBOutlet weak var gradingPeriodLabel: DynamicLabel!
    @IBOutlet weak var gradingPeriodView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    public weak var colorDelegate: ColorDelegate?
    public weak var gradesCellIconDelegate: GradesCellIconIconProviderProtocol?

    let env = AppEnvironment.shared
    var courseID: String!
    var grades: Grades!
    var userID: String?

    public static func create(courseID: String, userID: String?, colorDelegate: ColorDelegate? = nil) -> GradesViewController {
        let vc = GradesViewController.loadFromStoryboard()
        vc.courseID = courseID
        vc.colorDelegate = colorDelegate
        vc.userID = userID
        vc.grades = Grades(courseID: courseID, userID: userID)
        return vc
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        filterButton.setTitleColor(colorDelegate?.iconColor, for: .normal)
        grades.subscribe { [weak self] in
            self?.update()
        }
        grades.refresh()
        if grades.isPending {
            loadingView.isHidden = false
            activityIndicator.startAnimating()
        }
    }

    func configureTableView() {
        let refresh = CircleRefreshControl()
        refresh.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        tableView.refreshControl = refresh
        tableView.separatorColor = .named(.borderMedium)
        tableView.tableHeaderView?.sizeToFit()
        tableView.tableFooterView = UIView()
        tableView.registerHeaderFooterView(SectionHeaderView.self)
        tableView.registerCell(GradesCell.self)
    }

    func update() {
        if grades.isPending {
            loadingView.isHidden = tableView.refreshControl?.isRefreshing == true
        } else {
            loadingView.isHidden = true
            tableView.refreshControl?.endRefreshing()
        }
        if loadingView.isHidden == false {
            activityIndicator.startAnimating()
        }

        tableView.reloadData()
        updateTotalGrade()
        updateGradingPeriods()
    }

    @objc func refresh(_ control: CircleRefreshControl) {
        grades.refresh()
    }

    @IBAction func actionUserDidClickFilter(_ sender: Any) {
        if grades.gradingPeriodID != nil {
            grades.gradingPeriodID = nil
        } else {
            let alert = UIAlertController(title: nil, message: NSLocalizedString("Filter by:", bundle: .core, comment: ""), preferredStyle: .actionSheet)
            alert.popoverPresentationController?.sourceView = filterButton
            alert.popoverPresentationController?.sourceRect = filterButton.bounds
            for gp in grades.gradingPeriods {
                if gp.title?.isEmpty ?? true { continue }
                let action = UIAlertAction(title: gp.title, style: .default) { [weak self] _ in
                    self?.grades.gradingPeriodID = gp.id
                }
                alert.addAction(action)
            }
            let cancel = UIAlertAction(title: NSLocalizedString("Cancel", bundle: .core, comment: ""), style: .destructive, handler: nil)
            alert.addAction(cancel)
            present(alert, animated: true, completion: nil)
        }
    }

    func updateTotalGrade() {
        if grades.course?.hideFinalGrades == true {
            totalGradeLabel.text = NSLocalizedString("N/A", bundle: .core, comment: "")
        } else {
            totalGradeLabel.text = grades.enrollment?.formattedCurrentScore(gradingPeriodID: grades.gradingPeriodID)
        }
    }

    func updateGradingPeriods() {
        gradingPeriodView.isHidden = grades.enrollment?.multipleGradingPeriodsEnabled != true
        gradingPeriodLabel.text = grades.gradingPeriod?.title ?? NSLocalizedString("All Grading Periods", bundle: .core, comment: "")
        if grades.gradingPeriod?.id == nil {
            filterButton.setTitle(NSLocalizedString("Filter", bundle: .core, comment: ""), for: .normal)
        } else {
            filterButton.setTitle(NSLocalizedString("Clear filter", bundle: .core, comment: ""), for: .normal)
        }
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateHeaderViewHeight()
    }

    func updateHeaderViewHeight() {
        guard let headerView = tableView.tableHeaderView else { return }
        let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        if headerView.frame.size.height != height {
            headerView.frame.size.height = height
            tableView.tableHeaderView = headerView
            view.setNeedsLayout()
        }
    }
}

extension GradesViewController: UITableViewDataSource, UITableViewDelegate {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return grades.assignments.sections?.count ?? 0
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return grades.assignments.sections?[section].numberOfObjects ?? 0
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let a = grades.assignments[indexPath]
        let cell: GradesCell = tableView.dequeue(for: indexPath)
        cell.update(a, userID: userID)
        cell.nameLabel.text = a?.name
        cell.typeImage.tintColor = colorDelegate?.iconColor ?? Brand.shared.buttonPrimaryBackground
        cell.accessibilityIdentifier = "grades-list.grades-list-row.cell-\(a?.id ?? "nil")"
        if let iconDelegate = gradesCellIconDelegate { cell.iconDelegate = iconDelegate }
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let assignment = grades.assignments[indexPath] else { return }
        env.router.route(to: .course(courseID, assignment: assignment.id), from: self)
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueHeaderFooter(SectionHeaderView.self)
        view.titleLabel?.text = grades.assignments[IndexPath(row: 0, section: section)]?.assignmentGroup?.name
        return view
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }

    public func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 22
    }
}

extension GradesViewController: HorizontalPagedMenuItem {
    public func menuItemWillBeDisplayed() {
        if grades.isPending == true && tableView.refreshControl?.isRefreshing == false {
            activityIndicator.startAnimating()
        } else if grades.isPending == true && tableView.refreshControl?.isRefreshing == true {
            let offset = tableView.contentOffset
            tableView.refreshControl?.endRefreshing()
            tableView.refreshControl?.beginRefreshing()
            tableView.contentOffset = offset
        }
    }
}

public class GradesCell: UITableViewCell, GradesCellIconIconProviderProtocol {
    @IBOutlet weak var nameLabel: DynamicLabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var typeImage: UIImageView!
    @IBOutlet weak var dueLabel: DynamicLabel!
    @IBOutlet weak var gradeLabel: DynamicLabel!
    @IBOutlet weak var statusLabel: DynamicLabel!
    weak var iconDelegate: GradesCellIconIconProviderProtocol?

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        loadFromXib()
        iconDelegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadFromXib()
    }

    func update(_ assignment: Assignment?, userID: String?) {
        let submission = assignment?.submissions?.first { $0.userID == userID }
        fullDivider = true
        typeImage.image = iconDelegate?.iconImage(forAssignment: assignment)
        nameLabel.text = assignment?.name
        gradeLabel.text = assignment.flatMap { GradeFormatter.string(from: $0, userID: userID, style: .medium) }
        dueLabel.text = assignment?.dueText
        statusLabel.isHidden = assignment?.isOnline != true
        statusLabel.text = submission?.status.text
        statusLabel.textColor = submission?.status.color
    }
}

public protocol GradesCellIconIconProviderProtocol: class {
    func iconImage(forAssignment: Assignment?) -> UIImage?
}

extension GradesCellIconIconProviderProtocol {
    public func iconImage(forAssignment: Assignment?) -> UIImage? { forAssignment?.icon }
}
