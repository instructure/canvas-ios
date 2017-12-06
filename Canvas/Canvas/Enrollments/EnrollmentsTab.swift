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
    
    

import CanvasCore

public func EnrollmentsTab(session: Session) throws -> UIViewController {
    let route: (UIViewController, URL)->() = { vc, url in
        let vcs = vc.tabBarController?.viewControllers ?? []
        guard let split = vcs.first as? SplitViewController else { return }
        guard let masterNav = split.masterNavigationController else { return }

        let handleEmpty = {
            let empty = EmptyViewController()
            let emptyNav = UINavigationController(rootViewController: empty)
            split.viewControllers = [masterNav, emptyNav]
        }
        
        if url.lastPathComponent == "tabs" {
            let tabsVC = Router.shared().controller(forHandling: url) as! TabsTableViewController
            masterNav.pushViewController(tabsVC, animated: true)

            if let routingURL = (tabsVC.collection.filter({ $0.isHome }).first ?? tabsVC.collection.first)?.routingURL(session) {
                tabsVC.selectedTabURL = routingURL
                if let homeTabVC = Router.shared().controller(forHandling: routingURL) {
                    let detailNav = UINavigationController(rootViewController: homeTabVC)
                    if (!split.isCollapsed) {
                        split.viewControllers = [masterNav, detailNav]
                    }
                } else {
                    handleEmpty()
                }
            } else {
                handleEmpty()
            }
        } else {
            if let ctx = ContextID(url: url) {
                let tabsURL = (session.baseURL as NSURL).appendingPathComponent(ctx.htmlPath)?.appendingPathComponent("tabs")
                let tabsVC = Router.shared().controller(forHandling: tabsURL) as! TabsTableViewController
                masterNav.pushViewController(tabsVC, animated: true)

                tabsVC.selectedTabURL = url

                if let detailVC = Router.shared().controller(forHandling: url) {
                    let detailNav = UINavigationController(rootViewController: detailVC)
                    split.viewControllers = [masterNav, detailNav]
                    split.shouldCollapseDetail = false
                } else {
                    handleEmpty()
                }
            }
        }
    }

    let coursesTitle = NSLocalizedString("Courses", comment: "Courses page title")
    let coursesPage = ControllerPage(title: coursesTitle, controller: try CoursesCollectionViewController(session: session, route: route))

    let groupsTitle = NSLocalizedString("Groups", comment: "Groups page title")
    let groupsPage = ControllerPage(title: groupsTitle, controller: try GroupsCollectionViewController(session: session, route: route))

    let enrollments = PagedViewController(pages: [
        coursesPage,
        groupsPage
    ])

    let enrollmentsNav = UINavigationController(rootViewController: enrollments)

    addProfileButton(session, viewController: enrollments)

    enrollmentsNav.tabBarItem.title = coursesTitle
    enrollmentsNav.tabBarItem.image = .icon(.course)
    enrollmentsNav.tabBarItem.selectedImage = .icon(.course, filled: true)
    
    let split = EnrollmentSplitController(session: session)
    split.viewControllers = [enrollmentsNav, UINavigationController(rootViewController:EmptyViewController())]
    
    enrollmentsNav.delegate = split
    return split
}


import TechDebt

class EnrollmentSplitController: SplitViewController {
    let session: Session

    init(session: Session) {
        self.session = session
        super.init()

        preferredDisplayMode = .allVisible
        definesPresentationContext = true
        viewControllers = [UINavigationController(rootViewController: UIViewController()), UINavigationController(rootViewController: UIViewController())]

        let coursesTitle = NSLocalizedString("Courses", comment: "Courses page title")

        tabBarItem.title = coursesTitle
        tabBarItem.image = .icon(.course)
        tabBarItem.selectedImage = .icon(.course, filled: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension EnrollmentSplitController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let masterNav = masterNavigationController, let coursesViewController = masterTopViewController, toVC == coursesViewController,
            let detailNav = detailNavigationController, detailNav != masterNav, operation == .pop {
            let emptyVC = EmptyViewController()
            detailNav.viewControllers = [emptyVC]
        }
        return nil
    }
}

// Needed for the above bug mentioned in comments
extension EnrollmentSplitController: UIGestureRecognizerDelegate { }


