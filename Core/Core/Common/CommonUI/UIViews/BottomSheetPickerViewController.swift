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
    let titleLabel = UILabel()
    let stackView = UIStackView()
    let mainStackView = UIStackView()
    private let topPadding: CGFloat = 8
    private let stackViewSpacing: CGFloat = 8
    private var frameSize: CGFloat = 0

    public override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    public static func create(title: String? = nil) -> BottomSheetPickerViewController {
        let controller = BottomSheetPickerViewController()
        controller.modalPresentationStyle = .custom
        controller.modalPresentationCapturesStatusBarAppearance = true
        controller.transitioningDelegate = BottomSheetTransitioningDelegate.shared
        if let title {
            controller.addTitle(title)
        }
        return controller
    }

    private func addTitle(_ title: String) {
        loadViewIfNeeded()
        titleLabel.font = .scaledNamedFont(.regular14)
        titleLabel.textColor = .textDark
        titleLabel.textAlignment = .center
        titleLabel.text = title
        titleLabel.accessibilityLabel = title
        titleLabel.accessibilityTraits = .header
        mainStackView.insertArrangedSubview(titleLabel, at: 0)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor {
            $0.isDarkInterface ? .backgroundLight : .backgroundLightest
        }
        mainStackView.addArrangedSubview(stackView)
        stackView.axis = .vertical

        view.addSubview(mainStackView)
        mainStackView.axis = .vertical
        mainStackView.spacing = stackViewSpacing
        mainStackView.pin(inside: view, leading: nil, trailing: nil, top: topPadding, bottom: nil)
        mainStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        mainStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        mainStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        addAccessiblityDismissButton()
    }

    private func calculateFrameSize() {
        loadViewIfNeeded()
        frameSize = 0
        stackView.arrangedSubviews.forEach {
            frameSize += $0.sizeThatFits(CGSize(width: view.bounds.size.width, height: .greatestFiniteMagnitude)).height
        }
        frameSize += titleLabel.sizeThatFits(CGSize(width: view.bounds.size.width, height: .greatestFiniteMagnitude)).height
    }

    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        calculateFrameSize()
        view.frame.size.height = topPadding + stackViewSpacing + frameSize + view.safeAreaInsets.bottom
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

    private func addAccessiblityDismissButton() {
        accessibilityCustomActions = [
            .init(name: String(localized: "Dismiss menu", bundle: .core),
                  actionHandler: { [weak self] _ in
                      self?.dismiss(animated: true)
                      return true
                  })
        ]
    }

    @objc func didSelect(_ button: UIButton) {
        dismiss(animated: true) {
            self.actions[button.tag].action()
        }
    }
}
