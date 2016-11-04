
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
import TooLegit
import SoLazy

private func nav(vc: UIViewController) -> UINavigationController {
    return UINavigationController(rootViewController: vc)
}

private func tabs(vcs: [UIViewController]) -> UITabBarController {
    let tabs = UITabBarController()
    tabs.viewControllers = vcs
    return tabs
}

class Navigator {
    private let splitViewController = UISplitViewController()
    
    let session: Session
    
    lazy var routeAction: RouteAction = { [weak self] source, url in
        try self?.navigate(source, destination: url)
    }

    init(session: Session) throws {
        self.session = session
        
        splitViewController.viewControllers = [
            tabs([
                try WeekViewController.tab(session, route: routeAction),
                try CoursesCollectionViewController.tab(session, route: routeAction),
                try InboxViewController.tab(session, route: routeAction)
            ]),
            nav(PlaceholderViewController())
        ]
    }
    
    var rootViewController: UIViewController {
        return splitViewController
    }
    
    var currentMasterNavigationController: UINavigationController {
        guard let tab = splitViewController.viewControllers[0] as? UITabBarController,
            nav = tab.selectedViewController as? UINavigationController else { ❨╯°□°❩╯⌢"Unexpected configuration!" }
        
        return nav
    }

    func showDetail(viewController: UIViewController) {
        if splitViewController.viewControllers.count == 1 {
            currentMasterNavigationController.pushViewController(viewController, animated: true)
        } else {
            guard let detailNav = splitViewController.viewControllers[1] as? UINavigationController else { ❨╯°□°❩╯⌢"Maybe I don't understand how split view controllers work?" }
            detailNav.viewControllers = [viewController]
        }
    }
    
    func present(presentation: Route.Presentation, viewController: UIViewController, from: UIViewController) {
        switch presentation {
        case .Master:
            currentMasterNavigationController.pushViewController(viewController, animated: true)
        case .Detail:
            showDetail(viewController)
        case .Modal(let style):
            viewController.modalPresentationStyle = style
            from.presentViewController(viewController, animated: true, completion: nil)
        }
    }
    
    func navigate(source: UIViewController, destination: NSURL) throws {
        for route in TeachRoutes {
            if let viewController = try route.constructViewController(routeAction, session: session, url: destination) {
                present(route.presentation, viewController: viewController, from: source)
            }
        }
    }
}
