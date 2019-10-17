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

public class GradesViewController: UIViewController {

    @IBOutlet weak var filterButton: DynamicButton!
    @IBOutlet weak var headerGradeHeader: DynamicLabel!
    @IBOutlet weak var headerGradeTotalLabel: DynamicLabel!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    private var presenter: GradesPresenter!
    @IBOutlet weak var loadingView: UIView!
    public weak var colorDelegate: ColorDelegate?
    static let dateParser: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss ZZ"
        return df
    }()

    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "EEEEMMMMd", options: 0, locale: NSLocale.current)
        return dateFormatter
    }()

    public static func create(courseID: String, studentID: String, colorDelegate: ColorDelegate? = nil) -> GradesViewController {
        let vc = GradesViewController.loadFromStoryboard()
        vc.colorDelegate = colorDelegate
        vc.presenter = GradesPresenter(view: vc, courseID: courseID, studentID: studentID)
        return vc
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        presenter.refresh()

        headerGradeHeader.text = NSLocalizedString("Total Grade", comment: "")
        filterButton.setTitle(presenter.filterButtonTitle, for: .normal)
        filterButton.setTitleColor(colorDelegate?.iconColor, for: .normal)
    }

    func setupTableView() {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        tableView.refreshControl = refresh

        tableView.registerHeaderFooterView(SectionHeaderView.self)
        tableView.registerCell(GradesCell.self)
    }

    @objc func refresh(_ control: UIRefreshControl) {
        presenter.refresh(force: true)
    }

    @IBAction func actionUserDidClickFilter(_ sender: Any) {
        if presenter.currentGradingPeriodID != nil {
            presenter.filterByGradingPeriod(nil)
            filterButton.setTitle(presenter.filterButtonTitle, for: .normal)
        } else {
            let alert = UIAlertController(title: nil, message: NSLocalizedString("Filter by:", comment: ""), preferredStyle: .actionSheet)
            for gp in presenter.gradingPeriods {
                let action = UIAlertAction(title: gp.title, style: .default) { [weak self] _ in
                    self?.presenter.filterByGradingPeriod(gp.id)
                    self?.filterButton.setTitle(self?.presenter.filterButtonTitle, for: .normal)
                }
                alert.addAction(action)
            }
            let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .destructive, handler: nil)
            alert.addAction(cancel)
            present(alert, animated: true, completion: nil)
        }
    }
}

extension GradesViewController: GradesViewProtocol {
    func update(isLoading: Bool) {
        tableView.reloadData()

        if !isLoading {
            loadingView.isHidden = true
            tableView?.refreshControl?.endRefreshing()
            view.setNeedsLayout()
        }
    }

    func updateScore(_ score: String?) {
        headerGradeTotalLabel.text = score
    }
}

extension GradesViewController: UITableViewDataSource, UITableViewDelegate {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return presenter.assignments.numberOfSections
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.assignments.numberOfObjects(inSection: section)
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let a = presenter.assignments[indexPath]
        let cell: GradesCell =  tableView.dequeue(for: indexPath)
        cell.update(a, studentID: presenter.studentID)
        cell.typeImage.tintColor = colorDelegate?.iconColor ?? Brand.shared.buttonPrimaryBackground
        return cell
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueHeaderFooter(SectionHeaderView.self)
        guard let sectionInfo = presenter.assignments.sectionInfo(inSection: section) else { return nil }

        if let date = GradesViewController.dateParser.date(from: sectionInfo.name), date != Date.distantFuture {
            view.titleLabel?.text = GradesViewController.dateFormatter.string(from: date)
        } else {
            view.titleLabel?.text = NSLocalizedString("No Due Date", comment: "")
        }
        return view
    }
}

extension GradesViewController: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isBottomReached() {
            presenter?.assignments.getNextPage()
        }
    }
}

public class GradesCell: UITableViewCell {

    @IBOutlet weak var nameLabel: DynamicLabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var typeImage: UIImageView!
    @IBOutlet weak var dueLabel: DynamicLabel!
    @IBOutlet weak var gradeLabel: DynamicLabel!

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        loadFromXib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadFromXib()
    }

    func update(_ a: Assignment?, studentID: String) {
        typeImage.image = a?.icon
        nameLabel.text = a?.name
        let grade = a?.multiUserSubmissionGradeText(studentID: studentID)
        gradeLabel.text = grade
        gradeLabel.isHidden = grade == nil
        dueLabel.text = a?.dueAt != nil ? a?.dueText : nil
        dueLabel.isHidden = a?.dueAt == nil
    }
}
