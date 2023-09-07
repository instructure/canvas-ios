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

    @IBInspectable
    public var iconName: String = "" {
        didSet {
            if let image = UIImage(named: iconName, in: .core, compatibleWith: nil) {
                icon = image
            }
        }
    }

    public var icon: UIImage? {
        didSet {
            iconView.layer.cornerRadius = 0
            iconView.contentMode = .scaleAspectFit
            iconView.load(url: nil)
            iconView.image = icon
        }
    }

    public func load(url: URL?) {
        iconView.layer.cornerRadius = 4
        iconView.contentMode = .scaleAspectFill
        iconView.load(url: url)
    }

    public var state: State? {
        didSet {
            statusIconView.isHidden = PublishedIconView.isAutohideEnabled
            statusIconView.backgroundColor = .backgroundLightest
            switch state {
            case .published:
                statusIconView.image = .publishSolid
                statusIconView.tintColor = UIColor.textSuccess
                accessibilityLabel = NSLocalizedString("Published", bundle: .core, comment: "")
            case .restricted:
                statusIconView.image = .cloudLockLine
                statusIconView.tintColor = UIColor.textDark
                accessibilityLabel = NSLocalizedString("Restricted", bundle: .core, comment: "")
            case .unpublished:
                statusIconView.image = .noSolid
                statusIconView.tintColor = UIColor.textDark
                accessibilityLabel = NSLocalizedString("Not Published", bundle: .core, comment: "")
            case .none:
                statusIconView.isHidden = true
                accessibilityLabel = nil
            }
        }
    }

    public func setState(locked: Bool?, hidden: Bool?, unlockAt: Date?, lockAt: Date?) {
        if locked == true {
            state = .unpublished
        } else if hidden == true || unlockAt != nil || lockAt != nil {
            state = .restricted
        } else {
            state = .published
        }
    }

    public var published: Bool {
        get { return state == .published }
        set { state = newValue ? .published : .unpublished }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        loadFromXib()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadFromXib()
    }
}
