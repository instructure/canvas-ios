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

import Foundation
import TooLegit
import AssignmentKit
import EnrollmentKit
import SoPretty
import SoPersistent
import ReactiveCocoa
import SwiftGrader
import SoLazy


class AssignmentsTableViewController: Assignment.TableViewController {
    let session: Session
    let context: ContextID
    let courseRefresher: Refresher
    
    init(session: Session, courseID: String) throws {
        self.session = session
        self.context = ContextID(id: courseID, context: .Course)
        self.courseRefresher = try Course.refresher(session)
        super.init()
        
        courseRefresher.refresh(false)
        let dataSource = session.enrollmentsDataSource
        
        prepare(try Assignment.collectionByAssignmentGroup(session, courseID: courseID), refresher: try Assignment.refresher(session, courseID: courseID)) { (assignment: Assignment)->ColorfulViewModel in
            let colorful = ColorfulViewModel(style: .Basic)
            
            colorful.title.value = assignment.name
            colorful.color <~ dataSource.producer(ContextID(id: courseID, context: .Course)).map { $0?.color ?? .prettyGray() }
            
            return colorful
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let assignment = collection[indexPath]
        
        do {
            try GradingNavigationViewController.present(self, for: assignment.id, in: context, with: session)
        } catch let e as NSError {
            e.report(alertUserFrom: self)
        }
    }
}
