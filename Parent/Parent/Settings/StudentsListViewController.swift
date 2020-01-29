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

import UIKit
import CanvasCore
import Core

typealias StudentsListSelectStudentAction = (_ session: Session, _ student: Student) -> Void

class StudentsListViewController: FetchedTableViewController<Student> {

    fileprivate let session: Session

    @objc var selectStudentAction: StudentsListSelectStudentAction?

    @objc init(session: Session) throws {
        self.session = session

        super.init()

        let emptyView = TableEmptyView.nibView()
        emptyView.textLabel.text = NSLocalizedString("No Students", comment: "Empty Students Text")
        emptyView.accessibilityLabel = emptyView.textLabel.text
        emptyView.accessibilityIdentifier = "students_empty_view"

        self.emptyView = emptyView

        _ = ColorScheme.observer

        let collection = try Student.observedStudentsCollection(session)
        let refresher = try Student.observedStudentsRefresher(session)
        prepare(collection, refresher: refresher, viewModelFactory: { student in
            SettingsObserveeCellViewModel(student: student, highlightColor: .named(.backgroundLight))
        })
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor.named(.backgroundGrouped)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let student = collection[indexPath]
        selectStudentAction?(session, student)
    }

    func refresh() {
        refresher?.refresh(true)
    }
}
