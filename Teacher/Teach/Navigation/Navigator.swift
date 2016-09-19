//
//  Navigator.swift
//  Teach
//
//  Created by Derrick Hathaway on 4/11/16.
//  Copyright © 2016 Instructure. All rights reserved.
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
