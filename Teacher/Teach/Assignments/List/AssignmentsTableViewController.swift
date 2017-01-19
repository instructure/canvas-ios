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
    
    

import Foundation
import AssignmentKit
import TooLegit
import EnrollmentKit
import SoLazy
import ReactiveSwift
import SoPersistent


class AssignmentsTableViewController: Assignment.TableViewController {
    let route: RouteAction
    
    init(session: Session, courseID: String, route: @escaping RouteAction) throws {
        self.route = route
        super.init()
        let dataSource = session.enrollmentsDataSource
        title = dataSource[ContextID(id: courseID, context: .course)]?.name
        prepare(try Assignment.collectionByDueDate(session, courseID: courseID), refresher: try Assignment.refresher(session, courseID: courseID)) { assignment in
            return viewModel(for: assignment, in: session)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        ❨╯°□°❩╯⌢"no storyboard support today... sorry"
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let assignment = collection[indexPath]
        
        do {
            try route(self, assignment.htmlURL)
        } catch let e as NSError {
            e.presentAlertFromViewController(self)
        }
    }
}
