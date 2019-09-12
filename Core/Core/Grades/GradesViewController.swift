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
    private var presenter: GradesPresenter?
    private var groups: [String] = []
    private var assignmentsByGroup: [[GradesPresenter.CellViewModel]] = []

    public static func create(courseID: String) -> GradesViewController {
        let vc = GradesViewController.loadFromStoryboard()
        vc.presenter = GradesPresenter(view: vc, courseID: courseID)
        return vc
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        presenter?.viewIsReady()
    }

    func setupTableView() {
        tableView.registerHeaderFooterView(SectionHeaderView.self)
        tableView.registerCell(GradesCell.self)
    }
}

extension GradesViewController: GradesViewProtocol {
    func update(groups: [String], assignmentsByGroup: [[GradesPresenter.CellViewModel]]) {
        self.groups = groups
        self.assignmentsByGroup = assignmentsByGroup
        tableView.reloadData()
    }
}

extension GradesViewController: UITableViewDataSource, UITableViewDelegate {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return groups.count
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return assignmentsByGroup[section].count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let a = assignmentsByGroup[indexPath.section][indexPath.row]
        let cell: GradesCell =  tableView.dequeue(for: indexPath)
        cell.nameLabel?.text = a.name
        cell.gradeLabel?.text = a.grade
        cell.typeImage.image = a.icon
        cell.accessoryType = .disclosureIndicator

        cell.statusLabel?.text = a.status
        cell.statusLabel?.isHidden = a.status == nil

        return cell
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueHeaderFooter(SectionHeaderView.self)
        view.titleLabel?.text = groups[section]
        let bg = UIView(); bg.backgroundColor = .named(.backgroundLight); view.backgroundView = bg
        return view
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
