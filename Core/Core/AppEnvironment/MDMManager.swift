//
// Copyright (C) 2019-present Instructure, Inc.
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

import Foundation

public class MDMLogin: NSObject {
    @objc public let host: String
    @objc public let username: String
    @objc public let password: String

    fileprivate init(host: String, username: String, password: String) {
        self.host = host
        self.username = username
        self.password = password
    }
}

@objc
public class MDMManager: NSObject {
    public static let MDMUserDefaultsKey = "com.apple.configuration.managed"
    @objc public static let shared = MDMManager()
    private var token: NSObjectProtocol?

    // Login
    public typealias LoginObserver = (MDMLogin) -> Void
    @objc public private(set) var login: MDMLogin?
    private var loginObservers: [LoginObserver] = []

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

    @objc
    public func onLoginConfigured(callback: @escaping LoginObserver) {
        if let login = login {
            callback(login)
            return
        }
        loginObservers.append(callback)
    }

    private func update() {
        updateLogin()
    }

    private func updateLogin() {
        var login: MDMLogin?
        defer { self.login = login }
        guard let defaults = UserDefaults.standard.dictionary(forKey: MDMManager.MDMUserDefaultsKey) else { return }
        guard let enableDemo = defaults["enableDemo"] as? Bool, enableDemo else { return }
        guard let host = defaults["host"] as? String else { return }
        guard let username = defaults["username"] as? String else { return }
        guard let password = defaults["password"] as? String else { return }
        login = MDMLogin(host: host, username: username, password: password)
        if let login = login {
            let observers = self.loginObservers
            observers.forEach { $0(login) }
            loginObservers = []
        }
    }
}
