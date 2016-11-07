//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    
    

import UIKit
import AssignmentKit
import SoPersistent
import TooLegit
import ReactiveCocoa

struct GradeCellViewModel: TableViewCellViewModel {
    let name: String
    let grade: String

    static func tableViewDidLoad(tableView: UITableView) {
        tableView.registerNib(UINib(nibName: "AssignmentCell", bundle: NSBundle(forClass: AppDelegate.self)), forCellReuseIdentifier: "AssignmentCell")
    }

    func cellForTableView(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AssignmentCell", forIndexPath: indexPath)
        cell.textLabel?.text = name
        cell.detailTextLabel?.text = grade
        return cell
    }
    
    init(assignment: Assignment) {
        name = assignment.name
        grade = assignment.grade
    }
}

class GradesList: Assignment.TableViewController {
    let session: Session

    init(session: Session, courseID: String) throws {
        self.session = session
        super.init()

        let collection = try Assignment.collectionByAssignmentGroup(session, courseID: courseID)
        let refresher = try Assignment.refresher(session, courseID: courseID)
        prepare(collection, refresher: refresher, viewModelFactory: AssignmentViewModel.init)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let assignment = collection[indexPath]
        do {
            let deets = try AssignmentDetailViewController.new(session, courseID: assignment.courseID, assignmentID: assignment.id)
            navigationController?.pushViewController(deets, animated: true)
        } catch let e as NSError {
            e.report(alertUserFrom: self)
        }
    }
}
