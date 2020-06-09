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

    let env = AppEnvironment.shared

    func update(_ item: ModuleItem, indexPath: IndexPath) {
        backgroundColor = .named(.backgroundLightest)
        isUserInteractionEnabled = env.app == .teacher || !item.isLocked
        nameLabel.text = item.title
        nameLabel.isEnabled = env.app == .teacher || !(item.lockedForUser || item.module?.state == .locked)
        nameLabel.textColor = nameLabel.isEnabled ? .named(.textDarkest) : .named(.textLight)
        nameLabel.font = UIFont.scaledNamedFont(item.masteryPath?.locked == true ? .semibold16Italic : .semibold16)
        iconView.image = item.masteryPath?.locked == true ? UIImage.icon(.lock) : item.type?.icon
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
        if let masteryPath = item.masteryPath, masteryPath.needsSelection, !masteryPath.locked {
            let format = NSLocalizedString("d_options", bundle: .core, comment: "")
            dueLabel.text = String.localizedStringWithFormat(format, masteryPath.numberOfOptions)
            dueLabel.textColor = tintColor
            accessoryView = UIImageView(image: .icon(.masteryPaths))
        } else {
            dueLabel.text = [dueAt, points, requirement].compactMap { $0 }.joined(separator: " | ")
            dueLabel.textColor = .named(.textDark)
            accessoryView = nil
        }
        dueLabel.isHidden = dueLabel.text == nil
        var a11yLabels = [item.type?.label, item.title, dueLabel.text]
        if item.isLocked {
            a11yLabels.append(NSLocalizedString("locked", bundle: .core, comment: ""))
        }
        accessibilityLabel = a11yLabels.compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: ", ")
        if !publishedIconView.isHidden {
            accessibilityLabel = [
                item.type?.label,
                item.title,
                item.published == true
                    ? NSLocalizedString("published", bundle: .core, comment: "")
                    : NSLocalizedString("unpublished", bundle: .core, comment: ""),
            ].compactMap { $0 }.joined(separator: ", ")
        }
        accessibilityIdentifier = "ModuleList.\(indexPath.section).\(indexPath.row)"
    }
}
