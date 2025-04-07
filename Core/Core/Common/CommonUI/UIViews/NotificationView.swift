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

import UIKit

public class NotificationView: UIView {

    public let messageLabel = UILabel()
    public var dismissHandler: EmptyHandler?
    let dismiss = UIButton()
    var showDismiss: Bool = false {
        didSet {
            dismiss.isHidden = !showDismiss
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    func commonInit() {
        let background = UIView()
        background.translatesAutoresizingMaskIntoConstraints = false
        background.layer.shadowColor =  UIColor.black.cgColor
        background.layer.shadowOpacity = 0.12
        background.layer.shadowOffset = CGSize(width: 0, height: 4)
        background.layer.shadowRadius = 10
        addSubview(background)

        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .backgroundLightest
        container.layer.cornerRadius = 8
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.backgroundInfo.cgColor
        container.layer.masksToBounds = true
        background.addSubview(container)

        let icon = UIImageView(image: .infoSolid)
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .center
        icon.backgroundColor = .backgroundInfo
        icon.tintColor = .textLightest
        container.addSubview(icon)

        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.font = .scaledNamedFont(.regular14)
        messageLabel.numberOfLines = 0
        container.addSubview(messageLabel)

        dismiss.translatesAutoresizingMaskIntoConstraints = false
        dismiss.addTarget(self, action: #selector(handleCloseButtonAction), for: .primaryActionTriggered)
        dismiss.setImage(.xLine, for: .normal)
        dismiss.tintColor = .textDark
        dismiss.contentMode = .center
        dismiss.isHidden = true
        dismiss.isUserInteractionEnabled = true
        container.addSubview(dismiss)

        container.pin(inside: background)
        NSLayoutConstraint.activate([
            background.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            background.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -16),
            background.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16),
            icon.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            icon.topAnchor.constraint(equalTo: container.topAnchor),
            icon.widthAnchor.constraint(equalToConstant: 48),
            icon.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            messageLabel.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 12),
            messageLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 21),
            messageLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -21),
            dismiss.leadingAnchor.constraint(equalTo: messageLabel.trailingAnchor, constant: 12),
            dismiss.widthAnchor.constraint(equalToConstant: 40),
            dismiss.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            dismiss.topAnchor.constraint(equalTo: container.topAnchor),
            dismiss.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
    }

    @objc func handleCloseButtonAction(_ sender: UIGestureRecognizer) {
        dismissHandler?()
    }
}
