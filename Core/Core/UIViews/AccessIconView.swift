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

@IBDesignable
open class AccessIconView: UIView {
    public enum State {
        case published, restricted, unpublished
    }

    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var statusIconView: UIImageView!

    public var icon: UIImage? {
        didSet {
            iconView.image = icon
        }
    }

    public var state: State? {
        didSet {
            statusIconView.isHidden = PublishedIconView.isAutohideEnabled
            statusIconView.backgroundColor = .named(.backgroundLightest)
            switch state {
            case .published:
                statusIconView.image = .icon(.publish, .solid)
                statusIconView.tintColor = UIColor.named(.textSuccess)
            case .restricted:
                statusIconView.image = .icon(.cloudLock, .line)
                statusIconView.tintColor = UIColor.named(.textDark)
            case .unpublished:
                statusIconView.image = .icon(.no, .solid)
                statusIconView.tintColor = UIColor.named(.textDark)
            case .none:
                statusIconView.isHidden = true
            }
        }
    }

    public var published: Bool {
        get { return state == .published }
        set { state = newValue ? .published : .unpublished }
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadFromXib()
    }
}
