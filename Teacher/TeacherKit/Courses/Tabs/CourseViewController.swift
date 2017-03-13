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
import EnrollmentKit
import SixtySix
import SoPersistent
import TooLegit
import ReactiveSwift

func colorfulTab(_ tab: Tab) -> ColorfulViewModel {
    let colorful = ColorfulViewModel(features: [.icon])
    
    colorful.color <~ TEnv.current.session.enrollmentsDataSource.color(for: tab.contextID)
    colorful.title.value = tab.label
    colorful.icon.value = tab.icon
    
    return colorful
}

public class CourseViewController: Tab.TableViewController {
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tab = collection[indexPath]

        TEnv.current.router.route(to: tab.url, from: self)
    }
}


extension CourseViewController: Destination {
    public static func visit(with courseID: (String)) throws -> UIViewController {
        let course = CourseViewController()
        
        let session = TEnv.current.session
        let refresher = try Tab.refresher(session, contextID: .course(withID: courseID))
        let collection = try Tab.collection(session, contextID: .course(withID: courseID))
        course.prepare(collection, refresher: refresher, viewModelFactory: colorfulTab)
        
        return course
    }
}
