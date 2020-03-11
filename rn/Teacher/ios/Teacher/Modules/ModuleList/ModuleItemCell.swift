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
import Core

class ModuleItemCell: UITableViewCell {
    static let IndentMultiplier: CGFloat = 10

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dueLabel: UILabel!
    @IBOutlet weak var iconView: IconView!
    @IBOutlet weak var publishedIconView: PublishedIconView!
    @IBOutlet weak var indentConstraint: NSLayoutConstraint!

    var item: ModuleItem? {
        didSet {
            backgroundColor = .named(.backgroundLightest)
            nameLabel.text = item?.title
            iconView.image = item?.type?.icon
            publishedIconView.published = item?.published
            indentConstraint.constant = CGFloat((item?.indent ?? 0)) * ModuleItemCell.IndentMultiplier
            dueLabel.isHidden = item?.dueAt == nil
            dueLabel.text = item?.dueAt.flatMap {
                String.localizedStringWithFormat(
                    "Due %@",
                    DateFormatter.localizedString(from: $0, dateStyle: .long, timeStyle: .short)
                )
            }
            if let item = item {
                accessibilityLabel = [
                    item.title,
                    item.published == true ? NSLocalizedString("published", comment: "") : NSLocalizedString("unpublished", comment: ""),
                ].joined(separator: ", ")
            } else {
                accessibilityLabel = nil
            }
        }
    }

    override func tintColorDidChange() {
        super.tintColorDidChange()
        iconView.tintColor = tintColor
    }
}
