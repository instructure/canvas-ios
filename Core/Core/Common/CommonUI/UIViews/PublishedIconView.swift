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

public class PublishedIconView: UIImageView {
    static var isAutohideEnabled = !Bundle.main.isTeacherApp

    public override func awakeFromNib() {
        super.awakeFromNib()
        isHidden = PublishedIconView.isAutohideEnabled
    }

    public var published: Bool? {
        didSet {
            switch published {
            case .some(true):
                image = .publishSolid
                tintColor = UIColor.backgroundSuccess
            case .some(false):
                image = .noSolid
                tintColor = UIColor.textDark
            case .none:
                image = nil
            }
        }
    }

    public func setupState(with fileAvilability: FileAvailability) {
        switch fileAvilability {
        case .published:
            published = true
        case .unpublished:
            published = false
        case .hidden:
            image = .offLine
            tintColor = UIColor.textWarning
        case .scheduledAvailability:
            image = .calendarMonthLine
            tintColor = UIColor.textWarning
        }
    }
}
