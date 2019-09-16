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

public class GradesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    private var presenter: GradesPresenter!
    @IBOutlet weak var loadingView: UIView!
    static let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss ZZ"
        return df
    }()

    public static func create(courseID: String) -> GradesViewController {
        let vc = GradesViewController.loadFromStoryboard()
        vc.presenter = GradesPresenter(view: vc, courseID: courseID)
        return vc
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        presenter.viewIsReady()
    }

    func setupTableView() {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        tableView.refreshControl = refresh

        tableView.registerHeaderFooterView(SectionHeaderView.self)
        tableView.registerCell(GradesCell.self)
    }

    @objc func refresh(_ control: UIRefreshControl) {
        presenter.assignments.refresh(force: true)
    }
}

extension GradesViewController: GradesViewProtocol {
    func update(isLoading: Bool) {
        tableView.reloadData()
        loadingView.isHidden = isLoading
        tableView?.refreshControl?.endRefreshing()
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
        cell.nameLabel?.text = a?.name
        cell.gradeLabel?.text = a?.gradesListGradeText
        cell.typeImage.image = a?.icon
        cell.accessoryType = .disclosureIndicator

        let status = a?.submissionStatusText
        cell.statusLabel?.text = status
        cell.statusLabel?.isHidden = status == nil

        return cell
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueHeaderFooter(SectionHeaderView.self)
        guard let sectionInfo = presenter.assignments.sectionInfo(inSection: section) else { return nil }

        if let date = GradesViewController.dateFormatter.date(from: sectionInfo.name), date != Date.distantFuture {
            view.titleLabel?.text = DateFormatter.localizedString(from: date, dateStyle: .long, timeStyle: .none)
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

    @IBOutlet weak var typeImage: UIImageView!
    @IBOutlet weak var gradeLabel: DynamicLabel!
    @IBOutlet weak var statusLabel: DynamicLabel!
    @IBOutlet weak var nameLabel: DynamicLabel!

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        loadFromXib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadFromXib()
    }
}
