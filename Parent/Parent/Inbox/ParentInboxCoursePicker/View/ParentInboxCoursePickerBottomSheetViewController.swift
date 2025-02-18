//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

import Foundation
import UIKit
import Core

public class ParentInboxCoursePickerBottomSheetViewController: UIViewController {
    let env = AppEnvironment.shared
    public override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    public static func create() -> ParentInboxCoursePickerBottomSheetViewController {
        let controller = ParentInboxCoursePickerBottomSheetViewController()
        controller.modalPresentationStyle = .custom
        controller.modalPresentationCapturesStatusBarAppearance = true
        controller.transitioningDelegate = BottomSheetTransitioningDelegate.shared
        return controller
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor {
            $0.isDarkInterface ? .backgroundLight : .backgroundLightest
        }
        view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        view.addSubview(ParentInboxCoursePickerAssembly.makeInboxCoursePickerViewController(env: env).view)
        addAccessiblityDismissButton()
    }

    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        view.frame.size.height = UIScreen.main.bounds.height / 2
    }

    private func addAccessiblityDismissButton() {
        accessibilityCustomActions = [
            .init(name: String(localized: "Dismiss menu", bundle: .core),
                  actionHandler: { [weak self] _ in
                      self?.dismiss(animated: true)
                      return true
                  })
        ]
    }
}
