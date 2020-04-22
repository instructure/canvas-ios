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
        isUserInteractionEnabled = !item.lockedForUser
        nameLabel.text = item.title
        nameLabel.isEnabled = !item.lockedForUser
        iconView.image = item.type?.icon
        publishedIconView.published = item.published
        indentConstraint.constant = CGFloat(item.indent) * ModuleItemCell.IndentMultiplier
        let dueAt = item.dueAt.flatMap { DateFormatter.localizedString(from: $0, dateStyle: .medium, timeStyle: .none) }
        let points = item.pointsPossible.flatMap {
            String.localizedStringWithFormat(
                NSLocalizedString("%@ pts", bundle: .core, comment: ""),
                NSNumber(value: $0)
            )
        }
        let requirement = item.completionRequirement?.description
        dueLabel.text = [dueAt, points, requirement].compactMap { $0 }.joined(separator: " | ")
        dueLabel.isHidden = dueLabel.text == nil
        accessibilityLabel = [item.title, dueLabel.text].compactMap { $0 }.joined(separator: ",")
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
