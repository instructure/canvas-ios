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
        var vcs = vc.tabBarController?.viewControllers ?? []
        let split = EnrollmentSplitController(session: session)

        let masterNav = UINavigationController()
        masterNav.view.backgroundColor = UIColor.white
        masterNav.delegate = split
        masterNav.interactivePopGestureRecognizer?.isEnabled = false
        
        let handleEmpty = {
            let empty = UIViewController()
            empty.view.backgroundColor = .white
            let emptyNav = UINavigationController(rootViewController: empty)
            split.viewControllers = [masterNav, emptyNav]
        }
        
        if url.lastPathComponent == "tabs" {
            let tabsVC = Router.shared().controller(forHandling: url) as! TabsTableViewController
            masterNav.viewControllers = [UIViewController(), tabsVC]

            if let routingURL = (tabsVC.collection.filter({ $0.isHome }).first ?? tabsVC.collection.first)?.routingURL(session) {
                tabsVC.selectedTabURL = routingURL
                if let homeTabVC = Router.shared().controller(forHandling: routingURL) {
                    let detailNav = UINavigationController(rootViewController: homeTabVC)
                    split.viewControllers = [masterNav, detailNav]
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
                masterNav.viewControllers = [UIViewController(), tabsVC]

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

        vcs[0] = split

        let snapshot = vc.tabBarController!.view.snapshotView(afterScreenUpdates: true)!
        let tabVCView = vc.tabBarController!.view
        let prevCenter = vc.tabBarController!.view.center
        let window = UIApplication.shared.delegate!.window!

        if let tabVCView = tabVCView {
            tabVCView.center = CGPoint(x: tabVCView.center.x + tabVCView.frame.size.width + 20 /* who knows why */, y: tabVCView.center.y)
            window?.insertSubview(snapshot, belowSubview: vc.tabBarController!.view)

            UIView.animate(withDuration: 0.3, animations: {
                vc.tabBarController?.setViewControllers(vcs, animated: false)
                tabVCView.center = prevCenter
                snapshot.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }, completion: { _ in
                snapshot.removeFromSuperview()
            })
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

    return enrollmentsNav
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

    var fakeController: UIViewController? {
        if let nav = viewControllers.first as? UINavigationController, let fake = nav.viewControllers.first {
            return fake
        }
        return nil
    }

    func navigateToCoursePicker() {
        guard let vc = fakeController else { return }
        guard let tabBarController = vc.tabBarController else { return }
        guard let window = UIApplication.shared.delegate?.window else { return }

        let enrollments = try! EnrollmentsTab(session: session)
        var vcs = tabBarController.viewControllers ?? []
        vcs[0] = enrollments

        let snapshot = tabBarController.view.snapshotView(afterScreenUpdates: false) ?? UIView()
        let tabVCView = tabBarController.view ?? UIView()

        tabVCView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        window?.insertSubview(snapshot, aboveSubview: tabVCView)

        UIView.animate(withDuration: 0.3, animations: {
            vc.tabBarController?.setViewControllers(vcs, animated: false)
            snapshot.center = CGPoint(x: tabVCView.center.x + tabVCView.frame.size.width + 20 /* who knows why */, y: tabVCView.center.y)
            tabVCView.transform = CGAffineTransform.identity
        }, completion: { _ in
            snapshot.removeFromSuperview()
        })
    }
}

extension EnrollmentSplitController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if viewController == fakeController {
            navigateToCoursePicker()
        }
    }

    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if toVC == fakeController {
            return NoPopAnimator()
        } else {
            return nil
        }
    }
}

class NoPopAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        delay(2.0) {
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}

// Needed for the above bug mentioned in comments
extension EnrollmentSplitController: UIGestureRecognizerDelegate { }


