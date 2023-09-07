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
import Combine

class ModuleItemCell: UITableViewCell {
    static let IndentMultiplier: CGFloat = 10

    @Injected(\.reachability) var reachability: ReachabilityProvider

    @IBOutlet weak var hStackView: UIStackView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dueLabel: UILabel!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var publishedIconView: PublishedIconView!
    @IBOutlet weak var indentConstraint: NSLayoutConstraint!
    @IBOutlet weak var completedStatusView: UIImageView!

    let env = AppEnvironment.shared
    var course: Course?
    var item: ModuleItem?
    let downloadButtonHelper = DownloadStatusProvider()

    func update(_ item: ModuleItem, course: Course?, indexPath: IndexPath, color: UIColor?) {
        self.course = course
        self.item = item
        backgroundColor = .backgroundLightest
        selectedBackgroundView = ContextCellBackgroundView.create(color: color)
        let isLocked = item.isLocked || item.masteryPath?.locked == true
        isUserInteractionEnabled = env.app == .teacher || !isLocked
        nameLabel.setText(item.title, style: .textCellTitle)
        nameLabel.isEnabled = isUserInteractionEnabled
        nameLabel.textColor = nameLabel.isEnabled ? .textDarkest : .textLight
        iconView.image = item.masteryPath?.locked == true ? UIImage.lockLine : item.type?.icon
        publishedIconView.published = item.published
        completedStatusView.isHidden = env.app == .teacher || item.completionRequirement == nil
        completedStatusView.image = item.completed == true ? .checkLine : .emptyLine
        completedStatusView.tintColor = item.completed == true ? .backgroundSuccess : .borderMedium
        indentConstraint.constant = CGFloat(item.indent) * ModuleItemCell.IndentMultiplier
        let dueAt = item.dueAt.flatMap { DateFormatter.localizedString(from: $0, dateStyle: .medium, timeStyle: .none) }
        let points: String? = item.pointsPossible.flatMap {
            if item.hideQuantitativeData {
                return nil
            } else {
                return String.localizedStringWithFormat(
                    NSLocalizedString("%@ pts", bundle: .core, comment: ""),
                    NSNumber(value: $0)
                )
            }
        }
        let requirement = item.completionRequirement?.description
        if let masteryPath = item.masteryPath, masteryPath.needsSelection, !masteryPath.locked {
            let format = NSLocalizedString("d_options", bundle: .core, comment: "")
            dueLabel.setText(String.localizedStringWithFormat(format, masteryPath.numberOfOptions), style: .textCellSupportingText)
            dueLabel.textColor = tintColor
            accessoryView = UIImageView(image: .masteryPathsLine)
        } else {
            dueLabel.setText([dueAt, points, requirement].compactMap { $0 }.joined(separator: " | "), style: .textCellSupportingText)
            dueLabel.textColor = .textDark
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
        nameLabel.accessibilityIdentifier = "ModuleList.\(indexPath.section).\(indexPath.row).nameLabel"
        dueLabel.accessibilityIdentifier = "ModuleList.\(indexPath.section).\(indexPath.row).dueLabel"
        prepareForDownload()
    }
}
