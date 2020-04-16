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

class ModuleSectionHeaderView: UITableViewHeaderFooterView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var publishedIconView: PublishedIconView!
    @IBOutlet weak var collapsableIndicator: UIImageView!

    var isExpanded = true
    var onTap: (() -> Void)?

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        loadFromXib().backgroundColor = .named(.backgroundLight)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadFromXib().backgroundColor = .named(.backgroundLight)
    }

    func update(_ module: Module, isExpanded: Bool, onTap: @escaping () -> Void) {
        self.isExpanded = isExpanded
        self.onTap = onTap
        titleLabel.text = module.name
        publishedIconView.published = module.published
        collapsableIndicator.transform = CGAffineTransform(rotationAngle: isExpanded ? 0 : .pi)
        accessibilityLabel = [
            module.name,
            publishedIconView.isHidden ? "" :
            module.published == true
                ? NSLocalizedString("published", bundle: .core, comment: "")
                : NSLocalizedString("unpublished", bundle: .core, comment: ""),
            isExpanded
                ? NSLocalizedString("expanded", bundle: .core, comment: "")
                : NSLocalizedString("collapsed", bundle: .core, comment: ""),
        ].joined(separator: ", ")
        accessibilityTraits.insert(.button)
    }

    @IBAction func handleTap() {
        isExpanded = !isExpanded
        UIView.animate(withDuration: 0.3) {
            self.collapsableIndicator.transform = CGAffineTransform(rotationAngle: self.isExpanded ? 0 : .pi)
            self.collapsableIndicator.layoutIfNeeded()
        }
        onTap?()
    }
}
