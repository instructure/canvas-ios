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

public class FilterHeaderView: UITableViewHeaderFooterView {
    public let titleLabel = UILabel()
    public let filterButton = UIButton(type: .system)

    public override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    func setup() {
        contentView.backgroundColor = .backgroundLightest
        contentView.autoresizingMask = [ .flexibleWidth, .flexibleHeight ]
        titleLabel.textColor = .textDarkest
        titleLabel.font = .scaledNamedFont(.heavy24)
        titleLabel.numberOfLines = 2
        titleLabel.accessibilityTraits = [ .header ]
        contentView.addSubview(titleLabel)
        titleLabel.pin(inside: contentView, leading: 16, trailing: nil, top: 16, bottom: 8)
        filterButton.setTitle(String(localized: "Filter", bundle: .core), for: .normal)
        filterButton.setTitleColor(Brand.shared.linkColor, for: .normal)
        filterButton.titleLabel?.font = .scaledNamedFont(.medium16)
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        filterButton.accessibilityTraits = [ .button ]
        contentView.addSubview(filterButton)
        NSLayoutConstraint.activate([
            filterButton.firstBaselineAnchor.constraint(equalTo: titleLabel.firstBaselineAnchor),
            filterButton.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 4),
            contentView.trailingAnchor.constraint(equalTo: filterButton.trailingAnchor, constant: 16)
        ])
    }
}
