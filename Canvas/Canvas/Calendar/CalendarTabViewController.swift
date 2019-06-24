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
import TechDebt
import Core

public func CalendarTabViewController(session: Session, route: @escaping (UIViewController, URL)->()) -> UIViewController {
    let calendarVC: UIViewController
    if UIDevice.current.userInterfaceIdiom == .phone {
        let monthVC = CalendarMonthViewController.new(session)
        monthVC.routeToURL = { url in
            route(monthVC, url)
        }
        calendarVC = monthVC
    } else {
        let splitVC = CalendarSplitMonthViewController.new(session)
        splitVC.routeToURL = { url in
            route(splitVC, url)
        }
        calendarVC = splitVC
    }
    
    calendarVC.tabBarItem.title = NSLocalizedString("Calendar", comment: "Calendar page title")
    calendarVC.tabBarItem.image = .icon(.calendarMonth, .line)
    calendarVC.tabBarItem.selectedImage = .icon(.calendarMonth, .solid)

    return calendarVC
}
