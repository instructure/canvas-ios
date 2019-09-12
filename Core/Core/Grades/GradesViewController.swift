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

    private var sections: Int = 1
    private var rows = [2, 2, 2]
    @IBOutlet weak var tableView: UITableView!
    private var color: UIColor?
    private var presenter: GradesPresenter?

    static func create(courseID: String = "165") -> GradesViewController {
        let vc = GradesViewController.loadFromStoryboard()
        vc.presenter = GradesPresenter(view: vc, courseID: courseID)
        return vc
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }

    func setupTableView() {
        tableView.registerHeaderFooterView(SectionHeaderView.self)
        tableView.registerCell(GradesCell.self)
    }
}

extension GradesViewController: GradesViewProtocol {
    func update() {
        tableView.reloadData()
    }
}

extension GradesViewController: UITableViewDataSource, UITableViewDelegate {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return sections
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows[section]
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GradesCell =  tableView.dequeue(for: indexPath)
        cell.nameLabel?.text = "assignment name"
        cell.gradeLabel?.text = "- 89/100"
        cell.typeImage.image = .icon(.assignment, .line)
        cell.accessoryType = .disclosureIndicator
        if indexPath.row % 2 == 0 {
            cell.statusLabel?.text = "submitted"
            cell.statusLabel?.isHidden = false
        } else {
            cell.statusLabel?.text = nil
            cell.statusLabel?.isHidden = true
        }
        return cell
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueHeaderFooter(SectionHeaderView.self)
        view.titleLabel?.text = "section \(section)"
        view.backgroundColor = .named(.backgroundLight)
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
