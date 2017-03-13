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
import SixtySix
import SoPersistent
import ReactiveSwift
import PageKit
import TooLegit

private func colorfulPageViewModel(session: Session, page: Page) -> ColorfulViewModel {
    
    let vm = ColorfulViewModel(features: page.frontPage ? [.token] : [])
    vm.title.value = page.title
    if page.frontPage {
        vm.tokenViewText.value = NSLocalizedString("Front Page", comment: "badge indicating front page")
    }
    vm.color <~ session.enrollmentsDataSource.color(for: page.contextID)
    
    return vm
}

private func route(from vc: UIViewController, to url: URL) {
    TEnv.current.router.route(to: url, from: vc)
}

class PagesTableViewController: Page.TableViewController, Destination {
    
    public static func visit(with courseID: (String)) throws -> UIViewController {
        let session = TEnv.current.session
        
        return try PagesTableViewController(session: session, contextID: .course(withID: courseID), viewModelFactory: colorfulPageViewModel, route: route)
    }
}
