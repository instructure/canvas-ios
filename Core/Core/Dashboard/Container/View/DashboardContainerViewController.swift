//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import UIKit

/**
 This custom navigation controllers wraps the pushed viewcontroller into a split view controller and pushes
 this instead of the original view controller. The purpose of why this needed is to work around a UIKit limitation
 that throws an error when we try to directly push a split view controller into a navigation controller. This subclass
 also synchronizes its navigation bar and the split view's navigation bar so only one is visible at a time.
 */
public class DashboardContainerViewController: HelmNavigationController {
    public typealias SplitViewController = UISplitViewController & UINavigationControllerDelegate
    private let splitViewControllerFactory: () -> SplitViewController

    public init(rootViewController: UIViewController,
                splitViewControllerFactory: @escaping () -> SplitViewController) {
        self.splitViewControllerFactory = splitViewControllerFactory
        super.init(rootViewController: rootViewController)
        self.delegate = self
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func show(_ vc: UIViewController, sender: Any?) {
        vc.addNavigationButton(.back(target: self, action: #selector(pop)), side: .left)

        let split = makeSplitViewController(masterViewController: vc)
        let container = UIViewController()
        container.embed(split, in: container.view)

        super.show(container, sender: sender)
    }

    // MARK: - UIGestureRecognizerDelegate

    /**
     The purpose of this override is to prevent the swipe-to-pop gesture recognizer working in case there are view controllers inside
     the split view controller's master area. In this case the split's navigation controller will handle the gesture and pop its view controller.
     When the nav controller in the split view ran out of view controllers we activate our gesture recogniser so the whole split view can be dismissed.
     */
    public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer == interactivePopGestureRecognizer else {
            return super.gestureRecognizerShouldBegin(gestureRecognizer)
        }

        guard viewControllers.count > 1,
              let split = viewControllers.last?.children.first as? UISplitViewController,
              let masterNav = split.masterNavigationController
        else {
            return false
        }

        return masterNav.viewControllers.count == 1
    }

    // MARK: - Private Methods

    @objc
    private func pop() {
        popViewController(animated: true)
    }

    private func makeSplitViewController(masterViewController: UIViewController) -> UIViewController {
        let split = splitViewControllerFactory()
        split.preferredDisplayMode = .oneBesideSecondary
        split.viewControllers = [
            HelmNavigationController(rootViewController: masterViewController),
            HelmNavigationController(rootViewController: EmptyViewController()),
        ]
        split.masterNavigationController?.delegate = split
        return split
    }
}

extension DashboardContainerViewController: UINavigationControllerDelegate {

    /**
     We are pushing a split view controller that has its own navigation controllers so to avoid having two navigation bars
     displaying on top of each other we hide the outer navigation bar so the split view can display as a full screen controller.
     */
     public func navigationController(_ navigationController: UINavigationController,
                                      willShow viewController: UIViewController, animated: Bool) {
         let isPush = navigationController.viewControllers.count > 1
         setNavigationBarHidden(isPush, animated: animated)
    }
}
