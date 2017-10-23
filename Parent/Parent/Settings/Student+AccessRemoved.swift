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
import CanvasCore

extension Student {
    static func refreshForAccessRemoved(session: Session, from currentViewController: UIViewController) {
        do {
            let refresher = try Student.observedStudentsRefresher(session)
            refresher.refreshingCompleted.observe { _ in
                Router.sharedInstance.routeToLoggedInViewController()
            }
            refresher.refresh(true)
        } catch let e as NSError {
            Router.sharedInstance.presentServerError(currentViewController, error: e)
        }
    }
}
