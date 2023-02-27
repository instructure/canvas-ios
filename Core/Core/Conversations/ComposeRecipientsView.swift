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

class ComposeRecipientsView: UIView {
    var context: Context?
    var recipients: [SearchRecipient] = [] {
        didSet { updatePills() }
    }

    var pills: [ComposeRecipientView] {
        return subviews.compactMap { $0 as? ComposeRecipientView }
    }

    var editButton: UIButton!
    var placeholder: UILabel!
    var additionalRecipients: UILabel!
    var isExpanded: Bool = UIAccessibility.isVoiceOverRunning

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
        addPlaceholder()
        addAdditionalRecipients()

        if UIAccessibility.isVoiceOverRunning == false {
            addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleIsExpanded(sender:))))
        }
    }

    func addEditButton() {
        editButton = UIButton(type: .system)
        editButton.configuration = UIButton.Configuration.plain()
        editButton.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        editButton.setImage(.addressBookLine, for: .normal)
        editButton.tintColor = .textDark
        editButton.translatesAutoresizingMaskIntoConstraints = false
        editButton.accessibilityLabel = NSLocalizedString("Edit Recipients", comment: "")
        addSubview(editButton)
        NSLayoutConstraint.activate([
            editButton.heightAnchor.constraint(equalToConstant: 44),
            editButton.widthAnchor.constraint(equalToConstant: 44),
            editButton.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            trailingAnchor.constraint(equalTo: editButton.trailingAnchor, constant: 6),
        ])
    }

    func addPlaceholder() {
        placeholder = UILabel()
        placeholder.translatesAutoresizingMaskIntoConstraints = false
        placeholder.text = NSLocalizedString("To", comment: "")
        placeholder.textColor = .ash
        placeholder.font = .scaledNamedFont(.medium16)
        addSubview(placeholder)
        NSLayoutConstraint.activate([
            placeholder.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            placeholder.topAnchor.constraint(equalTo: topAnchor, constant: 19),
            bottomAnchor.constraint(greaterThanOrEqualTo: placeholder.bottomAnchor, constant: 18),
        ])
    }

    func addAdditionalRecipients() {
        additionalRecipients = UILabel()
        additionalRecipients.translatesAutoresizingMaskIntoConstraints = false
        additionalRecipients.textColor = .textDarkest
        additionalRecipients.font = .scaledNamedFont(.semibold16)
        addSubview(additionalRecipients)
        NSLayoutConstraint.activate([
            additionalRecipients.topAnchor.constraint(equalTo: topAnchor, constant: 19),
            bottomAnchor.constraint(greaterThanOrEqualTo: additionalRecipients.bottomAnchor, constant: 18),
        ])
    }

    @objc
    func toggleIsExpanded(sender: UITapGestureRecognizer) {
        isExpanded = !isExpanded
        updatePills()
    }

    func updatePills() {
        additionalRecipients.text = String.localizedStringWithFormat(NSLocalizedString("+%d", bundle: .core, comment: ""), recipients.count - 1)
        additionalRecipients.isHidden = recipients.count <= 1 || isExpanded

        pills.forEach { $0.removeFromSuperview() }

        for recipient in recipients.dropLast(isExpanded ? 0 : max(recipients.count - 1, 0)) {
            let pill = ComposeRecipientView()
            addSubview(pill)
            pill.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, constant: -32).isActive = true
            pill.update(recipient, context: context)
            setNeedsLayout()
        }

        for pill in pills.dropFirst(recipients.count) {
            pill.removeFromSuperview()
            setNeedsLayout()
        }
        placeholder.isHidden = !pills.isEmpty
        placeholder.setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let xPad: CGFloat = 16
        let yPad: CGFloat = 8
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
        height?.constant = max(next.y + lineHeight + yPad, placeholder.intrinsicContentSize.height)

        additionalRecipients.frame.origin.x = next.x
    }
}

class ComposeRecipientView: UIView {
    let avatarView = AvatarView()
    let nameLabel = UILabel()
    let roleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .backgroundLight
        layer.cornerRadius = 20
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(avatarView)
        avatarView.pin(inside: self, leading: 4, trailing: nil, top: 4, bottom: 4)
        addSubview(nameLabel)
        nameLabel.pin(inside: self, leading: nil, trailing: 16, top: 5, bottom: nil)
        nameLabel.font = .scaledNamedFont(.semibold14)
        nameLabel.textColor = .textDarkest
        addSubview(roleLabel)
        roleLabel.pin(inside: self, leading: nil, trailing: 16, top: nil, bottom: 5)
        roleLabel.font = .scaledNamedFont(.semibold11)
        roleLabel.textColor = .textDarkest
        NSLayoutConstraint.activate([
            avatarView.widthAnchor.constraint(equalToConstant: 32),
            avatarView.heightAnchor.constraint(equalToConstant: 32),
            nameLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 8),
            roleLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            roleLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 8),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("\(#function) not implemented")
    }

    func update(_ recipient: SearchRecipient, context: Context?) {
        avatarView.name = recipient.name
        avatarView.url = recipient.avatarURL
        nameLabel.text = recipient.displayName
        nameLabel.accessibilityIdentifier = "Compose.recipientName.\(recipient.id)"
        roleLabel.accessibilityIdentifier = "Compose.recipientRole.\(recipient.id)"
        roleLabel.text = ListFormatter.localizedString(from: recipient.commonCourses
            .filter { $0.courseID == context?.id }
            .compactMap { Role(rawValue: $0.role)?.description() }
        )
    }
}
