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
import TechDebt

public func EnrollmentsTab(session: Session) throws -> UIViewController {
    let _: (UIViewController, URL)->() = { vc, url in
        let vcs = vc.tabBarController?.viewControllers ?? []
        guard let split = vcs.first as? UISplitViewController else { return }
        guard let masterNav = split.masterNavigationController else { return }
        let detailNav = split.detailNavigationController

        let handleEmpty = {
            let empty = EmptyViewController()
            let emptyNav = UINavigationController(rootViewController: empty)
            detailNav?.viewControllers = [emptyNav]
        }
        
        if url.lastPathComponent == "tabs" {
            let tabsVC = Router.shared().controller(forHandling: url) as! TabsTableViewController
            masterNav.pushViewController(tabsVC, animated: true)

            if let routingURL = (tabsVC.collection.filter({ $0.isHome }).first ?? tabsVC.collection.first)?.routingURL(session) {
                tabsVC.selectedTabURL = routingURL
                if let homeTabVC = Router.shared().controller(forHandling: routingURL) {
                    detailNav?.viewControllers = [homeTabVC]
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
                    detailNav?.viewControllers = [detailVC]
                } else {
                    handleEmpty()
                }
            }
        }
    }

    let dashboardVC = HelmViewController(moduleName: "/", props: [:])
    let dashboardNav = HelmNavigationController(rootViewController: dashboardVC)
    let dashboardSplit = EnrollmentSplitViewController()
    let emptyNav = UINavigationController(rootViewController:EmptyViewController())
    emptyNav.navigationBar.isTranslucent = false
    dashboardNav.delegate = dashboardSplit
    dashboardSplit.viewControllers = [dashboardNav, emptyNav]
    dashboardSplit.tabBarItem.title = NSLocalizedString("Dashboard", comment: "dashboard page title")
    dashboardSplit.tabBarItem.image = .icon(.course)
    dashboardSplit.navigationItem.titleView = Brand.current.navBarTitleView()
    return dashboardSplit
}
