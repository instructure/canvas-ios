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

class CoursesViewController: UIViewController, CoursesView {
    var presenter: CoursesPresenter?

    @IBOutlet weak var tableView: UITableView!
    let activityIndicator = UIActivityIndicatorView(style: .white)

    static func create(environment: AppEnvironment = .shared, selectedCourseID: String?, callback: @escaping (Course) -> Void) -> CoursesViewController {
        let view = loadFromStoryboard()
        let presenter = CoursesPresenter(environment: environment, selectedCourseID: selectedCourseID, callback: callback)
        view.presenter = presenter
        presenter.view = view
        return view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("Courses", bundle: .core, comment: "")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        view.backgroundColor = .clear

        activityIndicator.hidesWhenStopped = true
        addNavigationButton(UIBarButtonItem(customView: activityIndicator), side: .right)

        presenter?.viewIsReady()
    }

    func update() {
        tableView.reloadData()
        presenter?.courses.pending == true ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }
}

extension CoursesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.courses.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "course-cell") ?? UITableViewCell(style: .default, reuseIdentifier: "course-cell")
        let course = presenter?.courses[indexPath]
        cell.textLabel?.text = course?.name
        cell.textLabel?.numberOfLines = 2
        cell.accessoryType = .none
        if presenter?.selectedCourseID != nil, course?.id == presenter?.selectedCourseID {
            cell.accessoryType = .checkmark
        }
        cell.contentView.backgroundColor = .clear
        cell.backgroundColor = .clear
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter?.selectCourse(at: indexPath)
    }
}

extension CoursesViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isBottomReached() {
            presenter?.getNextPage()
        }
    }
}
