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
import TooLegit
import SoPersistent
import Peeps
import SixtySix
import ReactiveSwift

func colorfulEnrollment(_ userEnrollment: UserEnrollment) -> ColorfulViewModel {
    let colorful = ColorfulViewModel(features: [.icon, .subtitle])
    
    colorful.color <~ TEnv.current.session.enrollmentsDataSource.color(for: .course(withID: userEnrollment.courseID))
    colorful.title.value = userEnrollment.user?.name ?? "No Name... that's weird"
    colorful.subtitle.value = userEnrollment.user?.email ?? ""
    
    return colorful
}


class PeopleViewController: UserEnrollment.TableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let peep = collection[indexPath]
        
        TEnv.current.router.route(to: peep.url, from: self)
    }
}

extension PeopleViewController: Destination {
    static func visit(with courseID: (String)) throws -> UIViewController {
        let peeps = PeopleViewController()
        
        let session = TEnv.current.session
        let collection = try UserEnrollment.collectionByRole(enrolledInCourseWithID: courseID, for: session)
        let refresher = try UserEnrollment.refresher(enrolledInCourseWithID: courseID, for: session)
        
        peeps.prepare(collection, refresher: refresher, viewModelFactory: colorfulEnrollment)
        
        return peeps
    }
}
