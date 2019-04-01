//
// Copyright (C) 2019-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
            nameLabel.text = item?.title
            iconView.image = item?.type?.icon
            publishedIconView.published = item?.published == true
            indentConstraint.constant = CGFloat((item?.indent ?? 0)) * ModuleItemCell.IndentMultiplier
            dueLabel.isHidden = item?.dueAt == nil
            dueLabel.text = item?.dueAt.flatMap {
                String.localizedStringWithFormat(
                    "Due %@",
                    DateFormatter.localizedString(from: $0, dateStyle: .long, timeStyle: .short)
                )
            }
        }
    }

    override func tintColorDidChange() {
        super.tintColorDidChange()
        iconView.tintColor = tintColor
    }
}
