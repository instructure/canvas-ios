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
        view.backgroundColor = UIColor {
            $0.isDarkInterface ? .backgroundLight : .backgroundLightest
        }
        view.addSubview(stackView)
        stackView.axis = .vertical
        stackView.pin(inside: view, leading: nil, trailing: nil, top: 8, bottom: nil)
        stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }

    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let topPadding: CGFloat = 8
        let buttonHeight: CGFloat = 56
        view.frame.size.height = topPadding + CGFloat(stackView.arrangedSubviews.count) * buttonHeight + view.safeAreaInsets.bottom
    }

    public func addAction(image: UIImage?, title: String, accessibilityIdentifier: String? = nil, action: @escaping () -> Void = {}) {
        loadViewIfNeeded()
        let button = UIButton(type: .system)
        button.configuration = UIButton.Configuration.plain()
        button.setTitle(title, for: .normal)
        button.contentHorizontalAlignment = .leading
        button.contentVerticalAlignment = .center
        button.tintColor = .textDarkest
        button.titleLabel?.font = .scaledNamedFont(.medium16)
        button.tag = actions.count
        button.accessibilityIdentifier = accessibilityIdentifier
        button.addTarget(self, action: #selector(didSelect(_:)), for: .primaryActionTriggered)
        button.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        if let image = image {
            button.setImage(image, for: .normal)
            button.configuration?.imagePadding = 24
        }

        stackView.addArrangedSubview(button)
        actions.append(BottomSheetAction(action: action, image: image, title: title))
    }

    @objc func didSelect(_ button: UIButton) {
        dismiss(animated: true) {
            self.actions[button.tag].action()
        }
    }
}
