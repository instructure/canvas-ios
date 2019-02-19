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
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var subtitleLabel: UILabel?

    public var title: String? {
        get { return titleLabel?.text }
        set { titleLabel?.text = newValue }
    }

    public var subtitle: String? {
        get { return subtitleLabel?.text }
        set { subtitleLabel?.text = newValue }
    }

    public static func create() -> TitleSubtitleView {
        let view = Bundle.loadView(self)
        view.titleLabel?.text = ""
        view.titleLabel?.textColor = .named(.white)
        view.subtitleLabel?.text = ""
        view.subtitleLabel?.textColor = .named(.white)
        return view
    }
}
