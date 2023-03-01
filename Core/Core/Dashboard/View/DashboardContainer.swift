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
import SwiftUI

public class DashboardContainerViewController: UIViewController {
    public typealias SplitViewController = UISplitViewController & UINavigationControllerDelegate
    public override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    // MARK: - Private State
    private var canShowViewController: Bool { pushedViewController == nil }
    private let baseNavController: UINavigationController
    private let splitViewControllerFactory: () -> SplitViewController
    private weak var pushedViewController: UIViewController?

    // MARK: - Public Methods

    public init(rootViewController: UINavigationController,
                splitViewControllerFactory: @escaping () -> SplitViewController) {
        self.baseNavController = rootViewController
        self.splitViewControllerFactory = splitViewControllerFactory
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        embed(baseNavController, in: view)
    }

    public func show(_ vc: UIViewController, from: UIViewController) {
        guard canShowViewController else {
            return from.show(vc, sender: nil)
        }

        setupSplitViewController(masterViewController: vc)
        vc.addNavigationButton(backButton, side: .left)

        animate(toVisible: true)
        pushFakeViewController()
    }

    public func popToRootViewController() {
        pop(toRoot: true)
    }

    // MARK: - Private Methods

    @objc private func pop(toRoot popToRoot: Bool = false) {
        if popToRoot {
            baseNavController.popToRootViewController(animated: true)
        } else {
            baseNavController.popViewController(animated: true)
        }

        animate(toVisible: false) {
            self.pushedViewController?.unembed()
        }
    }

    private var backButton: UIBarButtonItem {
        let backImage = UIImage(named: "chevron.backward", in: .core, with: nil)
//        let button = UIButton(type: .system)
//        button.addTarget(self, action: #selector(pop), for: .primaryActionTriggered)
//        button.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
//        button.setImage(backImage, for: .normal)
//        button.contentHorizontalAlignment = .left
//        let barButton = UIBarButtonItem(customView: button)

        let barButton = UIBarButtonItem(image: backImage, style: .plain, target: self, action: #selector(pop))
        barButton.imageInsets = .init(top: 0, left: -7, bottom: 0, right: 0)
        return barButton
    }

    private func pushFakeViewController() {
        let fake = UIViewController()
        fake.view.alpha = 0
        fake.navigationItem.hidesBackButton = true
        baseNavController.pushViewController(fake, animated: true)
    }

    private func setupSplitViewController(masterViewController: UIViewController) {
        let split = splitViewControllerFactory()
        split.preferredDisplayMode = .oneBesideSecondary
        split.viewControllers = [
            HelmNavigationController(rootViewController: masterViewController),
            HelmNavigationController(rootViewController: EmptyViewController()),
        ]
        split.masterNavigationController?.delegate = split

        embed(split, in: view)
        pushedViewController = split
    }

    private func animate(toVisible: Bool, completion: (() -> Void)? = nil) {
        guard let pushedView = pushedViewController?.view else {
            return
        }

        var newFrame = pushedView.frame
        newFrame.origin.x = (toVisible ? view.frame.width : 0)
        pushedView.frame = newFrame

        UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseOut, animations: {
            var newFrame = pushedView.frame
            newFrame.origin.x = (toVisible ? 0 : self.view.frame.width)
            pushedView.frame = newFrame
        }, completion: { _ in completion?() })
    }
}

extension UIViewController {
    public var dashboardContainer: DashboardContainerViewController? {
        findParentViewController()
    }
}
