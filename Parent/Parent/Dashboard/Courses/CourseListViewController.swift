//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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

import CanvasCore
import Core

class CourseListViewController: FetchedTableViewController<CanvasCore.Course> {

    fileprivate let session: Session
    fileprivate let observeeID: String

    var courseCollection: FetchedCollection<CanvasCore.Course>?

    @objc init(session: Session, studentID: String) throws {
        self.session = session
        self.observeeID = studentID

        super.init()

        let emptyView = TableEmptyView.nibView()
        emptyView.textLabel.text = NSLocalizedString("No Courses", comment: "Empty Courses Text")
        emptyView.textLabel.textColor = .black
        emptyView.subtext = NSLocalizedString("This student's courses may not be published yet.", comment: "")
        emptyView.accessibilityLabel = emptyView.textLabel.text
        emptyView.accessibilityIdentifier = "courses_empty_view"
        self.emptyView = emptyView

        let collection = try Course.collectionByStudent(session, studentID: studentID)
        let refresher = try Course.airwolfCollectionRefresher(session, studentID: studentID)
        prepare(collection, refresher: refresher, viewModelFactory: { course in
            CourseCellViewModel(course: course, highlightColor: .named(.backgroundLight))
        })
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor.white
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let course = collection[indexPath]
        AppEnvironment.shared.router.route(to: "/courses/\(course.id)/grades", from: self)
    }
}
