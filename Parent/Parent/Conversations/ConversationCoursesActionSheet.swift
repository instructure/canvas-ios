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
import CoreData

protocol ConversationCoursesActionSheetDelegate: class {
    func courseSelected(course: Course, user: User)
}

class ConversationCoursesActionSheet: UITableViewController, ErrorViewController {
    let env: AppEnvironment = .shared
    weak var delegate: ConversationCoursesActionSheetDelegate?
    let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))

    lazy var enrollments = env.subscribe(GetConversationCourses()) { [weak self] in
        self?.update()
    }

    static func create(delegate: ConversationCoursesActionSheetDelegate) -> ConversationCoursesActionSheet {
        let vc = ConversationCoursesActionSheet()
        vc.delegate = delegate
        return vc
    }

    override func viewDidLoad() {
        navigationItem.title = NSLocalizedString("Choose a course to message", bundle: .parent, comment: "")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.registerCell(SubtitleTableViewCell.self)

        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.startAnimating()
        loadingIndicator.center.x = tableView.center.x
        loadingIndicator.center.y = tableView.center.y / 2 // the table view hasn't yet been shrunk to activity sheet size
        loadingIndicator.center.y -= 48 // minus header height to get centered
        view.addSubview(loadingIndicator)

        enrollments.exhaust()
    }

    func update() {
        if !enrollments.pending {
            loadingIndicator.stopAnimating()
        }

        if let error = enrollments.error {
            showError(error)
        }

        self.tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if enrollments.pending {
            return 0
        }

        return enrollments.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SubtitleTableViewCell = tableView.dequeue(for: indexPath)
        guard let enrollment = enrollments[indexPath.row], let course = enrollment.course else {
            return cell
        }

        cell.textLabel?.text = course.name
        cell.detailTextLabel?.text = String.localizedStringWithFormat(NSLocalizedString("for %@", bundle: .parent, comment: ""), enrollment.observedUser?.name ?? "")
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let enrollment = enrollments[indexPath.row], let course = enrollment.course, let observedUser = enrollment.observedUser else {
            return
        }
        dismiss(animated: true) { [weak self] in
            self?.delegate?.courseSelected(course: course, user: observedUser)
        }
    }
}
