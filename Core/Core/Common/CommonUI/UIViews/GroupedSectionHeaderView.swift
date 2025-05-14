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

public class GroupedSectionHeaderView: UITableViewHeaderFooterView {
    public let titleLabel = UILabel()

    public override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundView = UIView()
        backgroundView?.backgroundColor = .backgroundLightest
        titleLabel.textColor = .textDark
        titleLabel.font = .scaledNamedFont(.semibold12)
        contentView.addSubview(titleLabel)
        titleLabel.pin(inside: contentView, leading: 16, trailing: 16, top: 16, bottom: 6)
        accessibilityTraits = [.header]
    }

    public override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        accessibilityLabel = nil
    }

    /// Use this method instead of setting `titleLabel.text` directly
    public func update(title: String, itemCount: Int) {
        titleLabel.text = title
        let countText = String.localizedNumberOfItems(itemCount)
        accessibilityLabel = "\(title), \(countText)"
    }
}
