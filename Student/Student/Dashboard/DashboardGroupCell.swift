//
// Copyright (C) 2018-present Instructure, Inc.
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

import UIKit

class DashboardGroupCell: UICollectionViewCell {
    @IBOutlet weak var leftColorView: UIView?
    @IBOutlet weak var groupNameLabel: UILabel?
    @IBOutlet weak var courseNameLabel: UILabel?
    @IBOutlet weak var termLabel: UILabel?

    func configure(with model: DashboardViewModel.Group) {
        groupNameLabel?.text = model.groupName
        groupNameLabel?.textColor = .named(.textDarkest)
        courseNameLabel?.text = model.courseName ?? ""
        courseNameLabel?.textColor = model.color?.ensureContrast(against: .white) ?? .black
        termLabel?.text = model.term ?? ""
        termLabel?.textColor = .named(.textDark)
        leftColorView?.backgroundColor = model.color ?? .black
    }
}
