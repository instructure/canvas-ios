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

import Foundation
import UIKit

public class SwitchTableViewCell: UITableViewCell {
    public let toggle = CoreSwitch()
    public var onToggleChange: (CoreSwitch) -> Void = { _ in }

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

        toggle.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(toggle)
        toggle.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        toggle.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor).isActive = true

        backgroundColor = .backgroundLightest
        directionalLayoutMargins = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
        heightAnchor.constraint(greaterThanOrEqualToConstant: 54).isActive = true
        textLabel?.textColor = .textDarkest
        textLabel?.font = .scaledNamedFont(.semibold16)
        textLabel?.accessibilityElementsHidden = true
    }

    @objc func toggleChanged(_ sender: CoreSwitch) {
        onToggleChange(sender)
    }
}

@available(iOS 17.0, *)
#Preview {
    let cell = SwitchTableViewCell(style: .default, reuseIdentifier: nil)
    cell.textLabel?.text = "test"
    return cell
}
