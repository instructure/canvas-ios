//
//  CourseListViewController.swift
//  Parent
//
//  Created by Brandon Pluim on 3/15/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import SoPersistent
import TooLegit
import EnrollmentKit
import Airwolf


typealias CourseListSelectCourseAction = (session: Session, observeeID: String, course: Course)->Void

class CourseListViewController: Course.TableViewController {

    private let session: Session
    private let observeeID: String

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

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let course = collection[indexPath]
        selectCourseAction?(session: session, observeeID: observeeID, course: course)
    }

}
