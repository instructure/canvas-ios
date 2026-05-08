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

public class SwitchTableViewCell: UITableViewCell {
    public let toggle = CoreSwitch()
    public var onToggleChange: (CoreSwitch) -> Void = { _ in }

    public let titleLabel = UILabel()
    public let subtitleLabel = UILabel()

    public override var textLabel: UILabel? { titleLabel }

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    func setup() {
        toggle.tintColor = Brand.shared.primary
        toggle.addTarget(self, action: #selector(toggleChanged(_:)), for: .valueChanged)

        titleLabel.textColor = .textDarkest
        titleLabel.font = .scaledNamedFont(.semibold16)
        titleLabel.numberOfLines = 0

        subtitleLabel.textColor = .textDark
        subtitleLabel.font = .scaledNamedFont(.regular14)
        subtitleLabel.numberOfLines = 0
        subtitleLabel.isHidden = true

        let labelStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        labelStack.axis = .vertical
        labelStack.spacing = 2
        labelStack.translatesAutoresizingMaskIntoConstraints = false

        toggle.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(labelStack)
        contentView.addSubview(toggle)

        NSLayoutConstraint.activate([
            labelStack.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            labelStack.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            labelStack.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            labelStack.trailingAnchor.constraint(lessThanOrEqualTo: toggle.leadingAnchor, constant: -8),
            toggle.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            toggle.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor)
        ])

        backgroundColor = .backgroundLightest
        directionalLayoutMargins = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
        heightAnchor.constraint(greaterThanOrEqualToConstant: 54).isActive = true
    }

    @objc func toggleChanged(_ sender: CoreSwitch) {
        onToggleChange(sender)
    }
}

#Preview {
    let cell = SwitchTableViewCell(style: .default, reuseIdentifier: nil)
    cell.titleLabel.text = "Anonymous Application Analytics"
    cell.subtitleLabel.text = "Help us improve by sharing anonymous usage data"
    cell.subtitleLabel.isHidden = false
    return cell
}
