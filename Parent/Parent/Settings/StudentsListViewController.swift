//
//  StudentsListViewController.swift
//  Peeps
//
//  Created by Brandon Pluim on 1/14/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import UIKit
import Airwolf
import SoPersistent
import TooLegit


typealias StudentsListSelectStudentAction = (session: Session, student: Student)->Void

class StudentsListViewController: Student.TableViewController {

    private let session: Session

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

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let student = collection[indexPath]
        selectStudentAction?(session: session, student: student)
    }
}