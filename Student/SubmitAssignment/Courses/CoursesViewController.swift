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

class CoursesViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    let activityIndicator = UIActivityIndicatorView(style: .white)

    let env = AppEnvironment.shared
    var selectedCourseID: String?
    var callback: ((Course) -> Void)?

    lazy var courses: Store<GetCourses> = env.subscribe(GetCourses()) { [weak self] in
        self?.update()
    }

    static func create(selectedCourseID: String?, callback: @escaping (Course) -> Void) -> CoursesViewController {
        let controller = loadFromStoryboard()
        controller.selectedCourseID = selectedCourseID
        controller.callback = callback
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Courses", comment: "")

        activityIndicator.hidesWhenStopped = true
        addNavigationButton(UIBarButtonItem(customView: activityIndicator), side: .right)

        courses.exhaust(force: true)
    }

    func update() {
        tableView.reloadData()
        courses.pending == true
            ? activityIndicator.startAnimating()
            : activityIndicator.stopAnimating()
    }
}

extension CoursesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courses.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeue(for: indexPath)
        let course = courses[indexPath]
        cell.isSelected = selectedCourseID != nil && course?.id == selectedCourseID
        cell.textLabel?.text = course?.name
        cell.textLabel?.numberOfLines = 2
        cell.accessoryType = cell.isSelected ? .checkmark : .none
        cell.contentView.backgroundColor = .clear
        cell.backgroundColor = .clear
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let course = courses[indexPath] {
            callback?(course)
        }
    }
}
