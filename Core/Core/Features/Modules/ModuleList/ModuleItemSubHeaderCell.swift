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

class ModuleItemSubHeaderCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var publishedIconView: PublishedIconView!
    @IBOutlet weak var indentConstraint: NSLayoutConstraint!

    let env = AppEnvironment.shared

    func update(_ item: ModuleItem) {
        backgroundColor = .backgroundLightest
        isUserInteractionEnabled = env.app == .teacher || !item.isLocked
        label.text = item.title
        label.isEnabled = isUserInteractionEnabled
        label.textColor = label.isEnabled ? .textDarkest : .textLight
        publishedIconView.published = item.published
        indentConstraint.constant = CGFloat(item.indent) * ModuleItemCell.IndentMultiplier
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
