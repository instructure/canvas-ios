//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

protocol LoginStartSessionDelegate: AnyObject {
    func removeSession(_ session: LoginSession)
}

class LoginStartSessionCell: UITableViewCell {
    @IBOutlet weak var avatarView: AvatarView?
    @IBOutlet weak var domainLabel: DynamicLabel?
    @IBOutlet weak var forgetButton: DynamicButton?
    @IBOutlet weak var nameLabel: DynamicLabel?

    var entry: LoginSession?
    weak var delegate: LoginStartSessionDelegate?

    func update(entry: LoginSession, delegate: LoginStartSessionDelegate) {
        self.entry = entry
        self.delegate = delegate
        let identifier = "LoginStartSession.\(entry.baseURL.host ?? "").\(entry.userID)"
        accessibilityIdentifier = identifier
        avatarView?.name = entry.userName
        avatarView?.url = entry.userAvatarURL
        backgroundColor = .backgroundLightest
        domainLabel?.text = entry.baseURL.host
        forgetButton?.accessibilityLabel = String.localizedStringWithFormat(String(localized: "Forget %@", bundle: .core), entry.userName)
        forgetButton?.accessibilityIdentifier = "\(identifier).removeButton"
        nameLabel?.text = entry.userName
    }

    @IBAction func removeTapped(_ sender: UIButton) {
        guard let entry = entry else { return }
        delegate?.removeSession(entry)
    }
}
