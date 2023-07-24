//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

public class ListBackgroundView: UIView {
    var insetObservation: NSKeyValueObservation?

    public override func awakeFromNib() {
        insetObservation = (superview as? UITableView)?.observe(\.contentInset, options: .new) { [weak self] _, _ in
            self?.setNeedsLayout()
        }
    }

    public override func layoutSubviews() {
        guard let tableView = superview as? UITableView else { return }
        if subviews.allSatisfy({ $0.isHidden }) {
            frame.size.height = 0
        } else {
            frame.size.height = tableView.frame.height - tableView.adjustedContentInset.top - frame.minY
        }

        super.layoutSubviews()
    }
}
