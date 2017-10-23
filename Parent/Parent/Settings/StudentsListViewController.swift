//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
    
import UIKit
import CanvasCore

typealias StudentsListSelectStudentAction = (_ session: Session, _ student: Student)->Void

class StudentsListViewController: FetchedTableViewController<Student> {

    fileprivate let session: Session

    var selectStudentAction: StudentsListSelectStudentAction? = nil

    init(session: Session) throws {
        self.session = session

        super.init()

        let emptyView = TableEmptyView.nibView()
        emptyView.textLabel.text = NSLocalizedString("No Students", comment: "Empty Students Text")
        emptyView.accessibilityLabel = emptyView.textLabel.text
        emptyView.accessibilityIdentifier = "students_empty_view"

        self.emptyView = emptyView

        let scheme = ColorCoordinator.colorSchemeForParent()

        let collection = try Student.observedStudentsCollection(session)
        let refresher = try Student.observedStudentsRefresher(session)
        prepare(collection, refresher: refresher, viewModelFactory: { student in
            SettingsObserveeCellViewModel(student: student, highlightColor: scheme.highlightCellColor)
        })
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor.defaultTableViewBackgroundColor()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let student = collection[indexPath]
        selectStudentAction?(session, student)
    }
}
