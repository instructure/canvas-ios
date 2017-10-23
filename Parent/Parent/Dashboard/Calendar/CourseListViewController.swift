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
    
    



import CanvasCore



typealias CourseListSelectCourseAction = (_ session: Session, _ observeeID: String, _ course: Course)->Void

class CourseListViewController: FetchedTableViewController<Course> {

    fileprivate let session: Session
    fileprivate let observeeID: String

    var courseCollection: FetchedCollection<Course>?
    var selectCourseAction: CourseListSelectCourseAction? = nil

    init(session: Session, studentID: String) throws {
        self.session = session
        self.observeeID = studentID

        super.init()

        let emptyView = TableEmptyView.nibView()
        emptyView.textLabel.text = NSLocalizedString("No Courses", comment: "Empty Courses Text")
        emptyView.imageView?.image = UIImage(named: "empty_courses")
        emptyView.accessibilityLabel = emptyView.textLabel.text
        emptyView.accessibilityIdentifier = "courses_empty_view"

        self.emptyView = emptyView

        let scheme = ColorCoordinator.colorSchemeForStudentID(studentID)

        let collection = try! Course.collectionByStudent(session, studentID: studentID)
        let refresher = try! Course.airwolfCollectionRefresher(session, studentID: studentID)
        prepare(collection, refresher: refresher, viewModelFactory: { course in
            CourseCellViewModel(course: course, highlightColor: scheme.highlightCellColor)
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
        let course = collection[indexPath]
        selectCourseAction?(session, observeeID, course)
    }

}
