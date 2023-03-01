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

public class DashboardContainer: HelmNavigationController {
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
        vc.addNavigationButton(backButton, side: .left)

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

    private var backButton: UIBarButtonItem {
        let backImage = UIImage(named: "chevron.backward", in: .core, with: nil)
        let barButton = UIBarButtonItem(image: backImage, style: .plain, target: self, action: #selector(popViewController))
        barButton.imageInsets = .init(top: 0, left: -7, bottom: 0, right: 0)
        return barButton
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

extension DashboardContainer: UINavigationControllerDelegate {

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
