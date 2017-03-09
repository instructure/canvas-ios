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
import UIKit
import SoLazy
import EnrollmentKit
import CalendarKit
import ReactiveSwift
import Kingfisher
import TechDebt
import TooLegit
import Peeps
import SoPretty


func rootViewController(_ session: Session) -> UIViewController {
    let tabs = CanvasTabBarController()
    
    do {
        // CALENDAR
        let calendar = try CalendarTabViewController(session: session) { vc, url in
            Router.shared().route(from: vc, to: url)
        }
        let calendarNav = UINavigationController(rootViewController: calendar)

        // TODO
        let todo = try ToDoTabViewController(session: session) { vc, url in
            Router.shared().route(from: vc, to: url)
        }


        tabs.viewControllers = [
            try EnrollmentsTab(session: session),
            calendarNav,
            todo,
            try NotificationsTab(session: session),
            MessagesTab()
        ]
    } catch let e as NSError {
        delay(0.1) {
            ErrorReporter.reportError(e, from: tabs)
        }
    }
    
    let selectedTab = UserPreferences.landingPage(session.user.id)
    tabs.selectedIndex = selectedTab.tabIndex

    return tabs
}
