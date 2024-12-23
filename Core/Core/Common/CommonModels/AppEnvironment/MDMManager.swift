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

public struct MDMLogin: Equatable {
    public let host: String
    public let username: String
    public let password: String
}

public class MDMManager: NSObject {
    public static let MDMUserDefaultsKey = "com.apple.configuration.managed"
    public static let shared = MDMManager()

    public private(set) var host: String?
    public private(set) var authenticationProvider: String?
    public private(set) var logins: [MDMLogin] = []
    @objc dynamic public private(set) var loginsRaw: [String: Any]?
    private var token: NSObjectProtocol?

    override init() {
        super.init()
        token = NotificationCenter.default.addObserver(forName: UserDefaults.didChangeNotification, object: nil, queue: .main) { [weak self] _ in
            self?.update()
        }
        update()
    }

    deinit {
        if let token = token {
            NotificationCenter.default.removeObserver(token)
        }
    }

    private func update() {
        logins = []
        let loginsRaw = UserDefaults.standard.dictionary(forKey: MDMManager.MDMUserDefaultsKey)
        defer { self.loginsRaw = loginsRaw }
        guard loginsRaw?["enableLogin"] as? Bool == true else { return }
        host = loginsRaw?["host"] as? String
        authenticationProvider = loginsRaw?["authenticationProvider"] as? String
        guard let users = loginsRaw?["users"] as? [[String: Any]] else { return }
        for user in users {
            guard let host = user["host"] as? String else { continue }
            guard let username = user["username"] as? String else { continue }
            guard let password = user["password"] as? String else { continue }
            logins.append(MDMLogin(host: host, username: username, password: password))
        }
    }
}
