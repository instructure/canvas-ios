//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

public class CoreWebViewController: UIViewController, CoreWebViewLinkDelegate {
    public let webView = CoreWebView()

    var limitedInteractionView: UIView?

    public var isInteractionLimited: Bool = false {
        didSet {
            webView.isLinkNavigationEnabled = !isInteractionLimited
            webView.allowsLinkPreview = !isInteractionLimited
        }
    }

    public init() {
        super.init(nibName: nil, bundle: nil)
        webView.linkDelegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(webView)
        webView.pin(inside: view)

        if isInteractionLimited {
            addLimitedInteractionExplanation()
        }
    }

    func addLimitedInteractionExplanation() {
        let background = UIView()
        background.translatesAutoresizingMaskIntoConstraints = false
        background.layer.shadowColor =  UIColor.black.cgColor
        background.layer.shadowOpacity = 0.15
        background.layer.shadowOffset = CGSize(width: 0, height: 4)
        background.layer.shadowRadius = 12
        view.addSubview(background)
        limitedInteractionView = background

        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .named(.backgroundLightest)
        container.layer.cornerRadius = 8
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.named(.backgroundInfo).cgColor
        container.layer.masksToBounds = true
        background.addSubview(container)

        let icon = UIImageView(image: .icon(.info, .solid))
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .center
        icon.backgroundColor = .named(.backgroundInfo)
        icon.tintColor = .named(.textLightest)
        container.addSubview(icon)

        let message = UILabel()
        message.translatesAutoresizingMaskIntoConstraints = false
        message.text = NSLocalizedString("Interactions on this page are limited by your institution.", comment: "")
        message.font = .scaledNamedFont(.regular14)
        message.numberOfLines = 0
        container.addSubview(message)

        let dismiss = UIImageView(image: .icon(.x))
        dismiss.translatesAutoresizingMaskIntoConstraints = false
        dismiss.tintColor = .named(.textDark)
        dismiss.contentMode = .center
        dismiss.isUserInteractionEnabled = true
        let dismissGesture = UITapGestureRecognizer(target: self, action: #selector(dismissLimitedInteraction(_:)))
        dismiss.addGestureRecognizer(dismissGesture)
        container.addSubview(dismiss)

        container.pin(inside: background)
        NSLayoutConstraint.activate([
            background.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            background.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            background.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            icon.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            icon.topAnchor.constraint(equalTo: container.topAnchor),
            icon.widthAnchor.constraint(equalToConstant: 48),
            icon.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            message.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 12),
            message.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            message.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12),
            dismiss.leadingAnchor.constraint(equalTo: message.trailingAnchor, constant: 12),
            dismiss.widthAnchor.constraint(equalToConstant: 40),
            dismiss.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            dismiss.topAnchor.constraint(equalTo: container.topAnchor),
            dismiss.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])
    }

    @objc func dismissLimitedInteraction(_ sender: UIGestureRecognizer) {
        limitedInteractionView?.removeFromSuperview()
    }
}
