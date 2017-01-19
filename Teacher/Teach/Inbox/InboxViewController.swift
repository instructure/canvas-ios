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
import SoIconic

private let inboxTitle = NSLocalizedString("Inbox", comment: "Title for Inbox view")
class InboxViewController: UIViewController {
    static func tab(_ session: Session, route: RouteAction) throws -> UIViewController {
        let nav = UINavigationController(rootViewController: InboxViewController())
        nav.tabBarItem.title = inboxTitle
        nav.tabBarItem.image = .icon(.inbox)
        nav.tabBarItem.selectedImage = .icon(.inbox, filled: true)
        return nav
    }
}
