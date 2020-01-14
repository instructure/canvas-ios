//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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
import Core

class ComposeRecipientsView: UIView {
    var recipients: [APIConversationRecipient] = [] {
        didSet { updatePills() }
    }

    var pills: [ComposeRecipientView] {
        return subviews.compactMap { $0 as? ComposeRecipientView }
    }

    var editButton: UIButton!

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }

    func initialize() {
        addEditButton()
    }

    func addEditButton() {
        editButton = UIButton(type: .system)
        editButton.setImage(.icon(.user), for: .normal)
        editButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(editButton)
        NSLayoutConstraint.activate([
            editButton.heightAnchor.constraint(equalToConstant: 24),
            editButton.widthAnchor.constraint(equalToConstant: 24),
            editButton.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            editButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
        ])
    }

    func updatePills() {
        for (i, recipient) in recipients.enumerated() {
            let pill: ComposeRecipientView
            if i < pills.count {
                pill = pills[i]
            } else {
                pill = ComposeRecipientView()
                addSubview(pill)
                pill.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, constant: -32).isActive = true
            }
            pill.update(recipient)
            setNeedsLayout()
        }
        for pill in pills.dropFirst(recipients.count) {
            pill.removeFromSuperview()
            setNeedsLayout()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let xPad: CGFloat = 16
        let yPad: CGFloat = 12
        let space: CGFloat = 8
        var next = CGPoint(x: xPad, y: yPad)
        let lineHeight = pills.first?.frame.height ?? 0
        for (index, pill) in pills.enumerated() {
            pill.layoutIfNeeded()
            let xMax = next.y == yPad ? editButton.frame.minX - xPad : bounds.maxX - xPad
            if next.x + pill.frame.width > xMax {
                next.x = xPad
                if index > 0 {
                    next.y += lineHeight + space
                }
            }
            pill.frame = CGRect(origin: next, size: pill.frame.size)
            next.x += pill.frame.width + space
        }
        let height = constraints.first { $0.firstAnchor == heightAnchor }
        height?.constant = next.y + lineHeight + yPad
    }
}

class ComposeRecipientView: UIView {
    let avatarView = AvatarView()
    let nameLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .named(.backgroundLight)
        layer.cornerRadius = 20
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(avatarView)
        avatarView.pin(inside: self, leading: 4, trailing: nil, top: 4, bottom: 4)
        addSubview(nameLabel)
        nameLabel.pin(inside: self, leading: nil, trailing: 16, top: 12, bottom: 12)
        nameLabel.font = .scaledNamedFont(.semibold14)
        nameLabel.textColor = .named(.textDarkest)
        NSLayoutConstraint.activate([
            avatarView.widthAnchor.constraint(equalToConstant: 32),
            avatarView.heightAnchor.constraint(equalToConstant: 32),
            nameLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 8),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("\(#function) not implemented")
    }

    func update(_ recipient: APIConversationRecipient) {
        avatarView.name = recipient.name
        avatarView.url = recipient.avatar_url?.rawValue
        nameLabel.text = recipient.name
    }
}
