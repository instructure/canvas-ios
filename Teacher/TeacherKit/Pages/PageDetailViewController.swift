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
import PageKit
import TooLegit
import SixtySix

private func getToRouting(from vc: UIViewController, to url: URL) {
    TEnv.current.router.route(to: url, from: vc)
}

class PageDetailViewController: Page.DetailViewController, Destination {
    static func visit(with parameters: (String, String)) throws -> UIViewController {
        let (courseID, pageID) = parameters
        
        let deets = try PageDetailViewController(session: TEnv.current.session, contextID: .course(withID: courseID), url: pageID, route: getToRouting)
        
        return deets
    }
}
