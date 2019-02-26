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

@IBDesignable
open class AccessIconView: UIView {
    public enum State {
        case published, unpublished
    }

    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var statusIconView: UIImageView!
    @IBOutlet weak var statusIconContainer: UIView!

    public var icon: UIImage? {
        didSet {
            iconView.image = icon
        }
    }

    public var state: State? {
        didSet {
            switch state {
            case .some(.published):
                statusIconView.image = .icon(.publish)
                statusIconView.tintColor = UIColor.named(.backgroundSuccess).ensureContrast(against: .white)
            case .some(.unpublished):
                statusIconView.image = .icon(.unpublish)
                statusIconView.tintColor = UIColor.named(.ash)
            case .none:
                statusIconView.isHidden = true
            }
        }
    }

    open override func awakeFromNib() {
        super.awakeFromNib()

        statusIconContainer.layer.cornerRadius = 8
        statusIconContainer.clipsToBounds = true
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        Bundle.loadView(for: self)
    }
}
