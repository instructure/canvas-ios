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

class PeopleListCell: UITableViewCell {
    @IBOutlet weak var avatar: AvatarView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var roles: UILabel!

    func update(user: User?) {
        backgroundColor = .named(.backgroundLightest)
        guard let user = user else {
            return
        }

        avatar.name = user.name
        avatar.url = user.avatarURL
        name.text = user.name
        let roles = user.enrollments?.compactMap { $0.formattedRole } ?? []
        self.roles.text = roles.joined(separator: ", ")
        self.roles.isHidden = roles.isEmpty
    }
}
