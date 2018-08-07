//
// Copyright (C) 2016-present Instructure, Inc.
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

open class TitleSubtitleView: UIView {
    // MARK: - IBOutlets
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var subtitleLabel: UILabel?

    open static func create(title: String, subtitle: String) -> TitleSubtitleView? {
        let view = Bundle.core.loadNibNamed("TitleSubtitleView", owner: self, options: nil)?.first as? TitleSubtitleView
        view?.titleLabel?.text = title
        view?.subtitleLabel?.text = subtitle
        return view
    }
}
