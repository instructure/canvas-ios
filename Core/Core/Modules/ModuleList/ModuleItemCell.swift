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

class ModuleItemCell: UITableViewCell {
    static let IndentMultiplier: CGFloat = 10

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dueLabel: UILabel!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var publishedIconView: PublishedIconView!
    @IBOutlet weak var indentConstraint: NSLayoutConstraint!

    func update(_ item: ModuleItem) {
        backgroundColor = .named(.backgroundLightest)
        nameLabel.text = item.title
        iconView.image = item.type?.icon
        publishedIconView.published = item.published
        indentConstraint.constant = CGFloat(item.indent) * ModuleItemCell.IndentMultiplier
        dueLabel.isHidden = item.dueAt == nil
        dueLabel.text = item.dueAt.flatMap {
            String.localizedStringWithFormat(
                NSLocalizedString("Due %@", bundle: .core, comment: ""),
                DateFormatter.localizedString(from: $0, dateStyle: .long, timeStyle: .short)
            )
        }
        accessibilityLabel = item.title
        if !publishedIconView.isHidden {
            accessibilityLabel = [
                item.title,
                item.published == true
                    ? NSLocalizedString("published", bundle: .core, comment: "")
                    : NSLocalizedString("unpublished", bundle: .core, comment: ""),
            ].joined(separator: ", ")
        }
    }
}
