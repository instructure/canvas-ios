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

public protocol LoginDelegate: class {
    var supportsCanvasNetwork: Bool { get }
    var helpURL: URL? { get }
    var whatsNewURL: URL? { get }

    func openExternalURL(_ url: URL)
    func openSupportTicket()
    func userDidLogin(keychainEntry: KeychainEntry)
    func userDidStartActing(as keychainEntry: KeychainEntry)
    func userDidStopActing(as keychainEntry: KeychainEntry)
    func userDidLogout(keychainEntry: KeychainEntry)
    func changeUser()
}

extension LoginDelegate {
    public var supportsCanvasNetwork: Bool { return true }
    public var helpURL: URL? { return URL(string: "https://community.canvaslms.com/docs/DOC-1543") }
    public var whatsNewURL: URL? { return nil }

    public func openSupportTicket() {}
    public func changeUser() {}

    public func userDidStartActing(as keychainEntry: KeychainEntry) {
        userDidLogin(keychainEntry: keychainEntry)
    }
    public func userDidStopActing(as keychainEntry: KeychainEntry) {
        userDidLogout(keychainEntry: keychainEntry)
    }

    public func startActing(as keychainEntry: KeychainEntry) {
        userDidStartActing(as: keychainEntry)
    }

    public func stopActing(as keychainEntry: KeychainEntry, findOriginalFrom entries: Set<KeychainEntry> = Keychain.entries) {
        guard let baseURL = keychainEntry.originalBaseURL, let userID = keychainEntry.originalUserID else { return }
        if let original = entries.first(where: { $0.baseURL == baseURL && $0.userID == userID && $0.masquerader == nil }) {
            userDidStopActing(as: keychainEntry)
            userDidLogin(keychainEntry: original.bumpLastUsedAt())
        } else {
            userDidLogout(keychainEntry: keychainEntry)
        }
    }
}
