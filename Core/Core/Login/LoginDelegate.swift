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

public protocol LoginDelegate: class {
    var loginLogo: UIImage { get }
    var supportsCanvasNetwork: Bool { get }
    var helpURL: URL? { get }
    var whatsNewURL: URL? { get }

    func openExternalURL(_ url: URL)
    func openSupportTicket()
    func userDidLogin(keychainEntry: KeychainEntry)
    func userDidLogout(keychainEntry: KeychainEntry)
    func changeUser()
}

extension LoginDelegate {
    public var supportsCanvasNetwork: Bool { return true }
    public var helpURL: URL? { return URL(string: "https://community.canvaslms.com/docs/DOC-1543") }
    public var whatsNewURL: URL? { return nil }

    public func openSupportTicket() {}
    public func changeUser() {}
}
