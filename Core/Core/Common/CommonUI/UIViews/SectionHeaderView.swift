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

public class SectionHeaderView: UITableViewHeaderFooterView {
    @IBOutlet weak public var titleLabel: UILabel!
    @IBOutlet weak var bgView: UIView!

    public override func awakeFromNib() {
        super.awakeFromNib()
        bgView.backgroundColor = .backgroundLight
    }

    public static func create(title: String, section: Int) -> SectionHeaderView {
        let view = loadFromXib()
        view.titleLabel.text = title
        return view
    }
}
