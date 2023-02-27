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

import CanvasCore
import Core
import UIKit
import SwiftUI

public class DashboardContainerViewController: UIViewController, DashboardContainerViewControllerProtocol {
    public var hasNoChildPresented: Bool { pushedViewController == nil }
    public override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    private let rootViewController: UIViewController
    private weak var pushedViewController: UIViewController?

    public init(rootViewController: UIViewController) {
        self.rootViewController = rootViewController
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        embed(rootViewController, in: view)
    }

    @objc public func pop() {
        animate(toVisible: false) {
            self.pushedViewController?.unembed()
            self.pushedViewController = nil
        }
    }

    public func push(_ vc: UIViewController) {
        let split = HelmSplitViewController()
        split.preferredDisplayMode = .oneBesideSecondary
        split.viewControllers = [
            HelmNavigationController(rootViewController: vc),
            HelmNavigationController(rootViewController: EmptyViewController()),
        ]
        split.masterNavigationController?.delegate = split

        embed(split, in: view)
        pushedViewController = split
        split.view.alpha = 0

        let button = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(pop))
        vc.addNavigationButton(button, side: .left)

        animate(toVisible: true)
    }

    private func animate(toVisible: Bool, completion: (() -> Void)? = nil) {
        guard let pushedView = pushedViewController?.view else {
            return
        }

        pushedView.alpha = (toVisible ? 0 : 1)
        var newFrame = pushedView.frame
        newFrame.origin.x = (toVisible ? view.frame.width : 0)
        pushedView.frame = newFrame

        UIView.animate(withDuration: 0.3, delay: 0, options: .transitionCrossDissolve, animations: {
            pushedView.alpha = (toVisible ? 1 : 0)
            var newFrame = pushedView.frame
            newFrame.origin.x = (toVisible ? 0 : self.view.frame.width)
            pushedView.frame = newFrame
        }, completion: { _ in completion?() })
    }
}
