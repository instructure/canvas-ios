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

class LoginStartMDMLoginCell: UITableViewCell {
    @IBOutlet weak var domainLabel: DynamicLabel?
    @IBOutlet weak var nameLabel: DynamicLabel?

    func update(login: MDMLogin) {
        let identifier = "LoginStartMDMLogin.\(login.host).\(login.username)"
        accessibilityIdentifier = identifier
        backgroundColor = .backgroundLightest
        domainLabel?.text = login.host
        nameLabel?.text = login.username
    }
}
