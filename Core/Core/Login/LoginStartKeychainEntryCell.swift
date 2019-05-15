//
// Copyright (C) 2018-present Instructure, Inc.
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

protocol LoginStartKeychainEntryDelegate: class {
    func removeKeychainEntry(_ entry: KeychainEntry)
}

class LoginStartKeychainEntryCell: UITableViewCell {
    @IBOutlet weak var avatarView: AvatarView?
    @IBOutlet weak var domainLabel: DynamicLabel?
    @IBOutlet weak var forgetButton: DynamicButton?
    @IBOutlet weak var nameLabel: DynamicLabel?

    var entry: KeychainEntry?
    weak var delegate: LoginStartKeychainEntryDelegate?

    func update(entry: KeychainEntry, delegate: LoginStartKeychainEntryDelegate) {
        self.entry = entry
        self.delegate = delegate
        let identifier = "LoginStartKeychainEntryCell.\(entry.baseURL.host ?? "").\(entry.userID)"
        self.accessibilityIdentifier = identifier
        avatarView?.name = entry.userName
        avatarView?.url = entry.userAvatarURL
        domainLabel?.text = entry.baseURL.host
        forgetButton?.accessibilityLabel = String.localizedStringWithFormat(NSLocalizedString("Forget %@", bundle: .core, comment: ""), entry.userName)
        forgetButton?.accessibilityIdentifier = "\(identifier).removeButton"
        nameLabel?.text = entry.userName
    }

    @IBAction func removeTapped(_ sender: UIButton) {
        guard let entry = entry else { return }
        delegate?.removeKeychainEntry(entry)
    }
}
