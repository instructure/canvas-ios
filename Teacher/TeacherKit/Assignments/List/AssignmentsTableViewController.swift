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
import SoPersistent
import SixtySix

public class AssignmentsTableViewController: Assignment.TableViewController, Destination {
    
    public static func visit(with courseID: String) throws -> UIViewController {
        let session = TEnv.current.session
        let dataSource = session.enrollmentsDataSource
        
        let me = AssignmentsTableViewController()
        me.title = dataSource[ContextID(id: courseID, context: .course)]?.name
        me.prepare(try Assignment.collectionByDueDate(session, courseID: courseID), refresher: try Assignment.refresher(session, courseID: courseID)) { assignment in
            return viewModel(for: assignment, in: session)
        }

        return me
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let assignment = collection[indexPath]
        TEnv.current.router.route(to: assignment.htmlURL, from: self)
    }
}
