//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

public struct BottomSheetAction {
    public let action: () -> Void
    public let image: UIImage?
    public let title: String
}

public class BottomSheetPickerViewController: UIViewController {
    let env = AppEnvironment.shared
    public private(set) var actions: [BottomSheetAction] = []
    let stackView = UIStackView()

    public override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    public static func create() -> BottomSheetPickerViewController {
        let controller = BottomSheetPickerViewController()
        controller.modalPresentationStyle = .custom
        controller.modalPresentationCapturesStatusBarAppearance = true
        controller.transitioningDelegate = BottomSheetTransitioningDelegate.shared
        return controller
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .named(.backgroundLightest)
        view.addSubview(stackView)
        stackView.axis = .vertical
        stackView.pin(inside: view, top: 8, bottom: nil)
        stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        view.frame.size.height = 8
    }

    func addAction(image: UIImage?, title: String, action: @escaping () -> Void = {}) {
        loadViewIfNeeded()
        let button = UIButton(type: .system)

        button.setTitle(title, for: .normal)
        button.contentHorizontalAlignment = .leading
        button.contentVerticalAlignment = .center
        button.tintColor = .named(.textDarkest)
        button.titleLabel?.font = .scaledNamedFont(.medium16)
        button.tag = actions.count
        button.addTarget(self, action: #selector(didSelect(_:)), for: .primaryActionTriggered)
        button.contentEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        if let image = image {
            button.contentEdgeInsets = UIEdgeInsets(top: 16, left: 40, bottom: 16, right: 16)
            button.setImage(image, for: .normal)
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -24, bottom: 0, right: 0)
        }

        button.sizeToFit()
        view.frame.size.height += button.frame.height
        stackView.addArrangedSubview(button)
        actions.append(BottomSheetAction(action: action, image: image, title: title))
    }

    @objc func didSelect(_ button: UIButton) {
        dismiss(animated: true) {
            self.actions[button.tag].action()
        }
    }
}
