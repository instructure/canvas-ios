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
import Core

class DashboardCourseCell: UICollectionViewCell {
    @IBOutlet var topView: UIView?
    @IBOutlet var optionsButton: UIButton?
    @IBOutlet var imageView: UIImageView?
    @IBOutlet var bottomView: UIView?
    @IBOutlet var titleLabel: UILabel?
    @IBOutlet var abbrevationLabel: UILabel?

    var optionsCallback: (() -> Void)?

    func configure(with model: DashboardViewModel.Course) {
        titleLabel?.text = model.title
        titleLabel?.textColor = model.color.ensureContrast(against: .white)
        abbrevationLabel?.text = model.abbreviation
        abbrevationLabel?.textColor = .named(.textDark)
        topView?.backgroundColor = model.color
        imageView?.load(url: model.imageUrl)
    }

    @IBAction func optionsButtonTapped(_ sender: Any) {
        optionsCallback?()
    }
}
