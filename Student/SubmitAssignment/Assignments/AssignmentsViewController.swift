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

import Core

class AssignmentsViewController: UIViewController {
    let env = AppEnvironment.shared
    var courseID: String!
    var selectedAssignmentID: String?
    var callback: ((Assignment) -> Void)?

    lazy var assignments = env.subscribe(GetSubmittableAssignments(courseID: courseID)) { [weak self] in
        self?.update()
    }

    @IBOutlet weak var tableView: UITableView!
    let activityIndicator = UIActivityIndicatorView(style: .white)

    static func create(courseID: String, selectedAssignmentID: String?, callback: @escaping (Assignment) -> Void) -> AssignmentsViewController {
        let view = loadFromStoryboard()
        view.courseID = courseID
        view.selectedAssignmentID = selectedAssignmentID
        view.callback = callback
        return view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("Assignments", bundle: .core, comment: "")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        view.backgroundColor = .clear

        activityIndicator.hidesWhenStopped = true
        addNavigationButton(UIBarButtonItem(customView: activityIndicator), side: .right)

        assignments.refresh(force: true)
    }

    func update() {
        tableView.reloadData()
        assignments.pending == true ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }
}

extension AssignmentsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = assignments.count
        if assignments.hasNextPage == true {
            count += 1
        }
        return count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == assignments.count {
            assignments.getNextPage()
            return LoadingCell(style: .default, reuseIdentifier: nil)
        }
        let cell: UITableViewCell = tableView.dequeue(for: indexPath)
        let assignment = assignments[indexPath]
        cell.textLabel?.text = assignment?.name
        cell.textLabel?.numberOfLines = 2
        cell.accessoryType = .none
        if selectedAssignmentID != nil, assignment?.id == selectedAssignmentID {
            cell.accessoryType = .checkmark
        }
        cell.contentView.backgroundColor = .clear
        cell.backgroundColor = .clear
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let assignment = assignments[indexPath] {
            callback?(assignment)
        }
    }
}

class LoadingCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let indicator = UIActivityIndicatorView(style: .gray)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
        indicator.startAnimating()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
