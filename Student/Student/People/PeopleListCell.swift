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
import Core

class PeopleListCell: UITableViewCell {
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var roles: UILabel!

    func update(searchRecipient: SearchRecipient?) {
        guard let searchRecipient = searchRecipient else {
            return
        }

        if let avatarURL = searchRecipient.avatarURL {
            avatar.setImageWith(avatarURL)
            avatar.roundCorners(corners: .allCorners, radius: avatar.frame.width / 2)
        }
        name.text = searchRecipient.fullName
        roles.text = searchRecipient.roles
        roles.isHidden = searchRecipient.roles == ""
    }
}
