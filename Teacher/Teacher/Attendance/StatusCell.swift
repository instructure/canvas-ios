//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
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

class StatusCell: UITableViewCell {
    let avatarView = AvatarView()
    let nameLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
        backgroundColor = .backgroundLightest

        nameLabel.font = .scaledNamedFont(.semibold16)
        nameLabel.textColor = .textDarkest

        let horizontalStack = UIStackView()
        horizontalStack.alignment = .center
        horizontalStack.spacing = 8
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false
        horizontalStack.addArrangedSubview(avatarView)
        horizontalStack.addArrangedSubview(nameLabel)

        let guide = contentView.layoutMarginsGuide
        contentView.addSubview(horizontalStack)
        NSLayoutConstraint.activate([
            avatarView.widthAnchor.constraint(equalToConstant: 40),
            avatarView.heightAnchor.constraint(equalToConstant: 40),
            guide.leadingAnchor.constraint(equalTo: horizontalStack.leadingAnchor),
            guide.trailingAnchor.constraint(equalTo: horizontalStack.trailingAnchor),
            guide.topAnchor.constraint(equalTo: horizontalStack.topAnchor),
            guide.bottomAnchor.constraint(equalTo: horizontalStack.bottomAnchor)
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var status: Status? {
        didSet {
            guard let status = status else { return }

            nameLabel.text = status.student?.name
            avatarView.name = status.student?.name ?? ""
            avatarView.url = status.student?.avatarURL

            var i18nLabel = status.student?.name ?? ""
            if let attendance = status.attendance {
                accessoryView = UIImageView(image: attendance.icon)
                accessoryView?.tintColor = attendance.tintColor
                i18nLabel += " — \(attendance.label)"
            } else {
                accessoryView = UIImageView(image: .noLine)
                accessoryView?.tintColor = .backgroundDark
                i18nLabel += " — \(String(localized: "Unmarked", bundle: .teacher))"
            }
            accessibilityLabel = i18nLabel
        }
    }
}
