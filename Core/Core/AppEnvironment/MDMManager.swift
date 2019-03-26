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

/// Manages MDM Configurations
///
/// You can test this locally with command line arguments
// -com.apple.configuration.managed '<dict><key>enableDemo</key><true/><key>username</key><string>username</string><key>password</key><string>password</string></dict>'
/// `username` and `password` values should match what's set in App Store Connect.

public class MDMLogin: NSObject {
    @objc
    public let host: String
    @objc
    public let username: String
    @objc
    public let password: String

    fileprivate init(host: String, username: String, password: String) {
        self.host = host
        self.username = username
        self.password = password
    }
}

enum MDMProvider: String, CaseIterable {
    case instructure = "com.instructure.configuration.managed"
    case apple = "com.apple.configuration.managed"

    var login: MDMLogin? {
        guard let defaults = defaults else { return nil }
        switch self {
        case .instructure:
            guard let enableLogin = defaults["enableLogin"] as? Bool, enableLogin else { return nil }
            guard let host = defaults["host"] as? String else { return nil }
            guard let username = defaults["username"] as? String else { return nil }
            guard let password = defaults["password"] as? String else { return nil }
            return MDMLogin(host: host, username: username, password: password)
        case .apple:
            guard let enableDemo = defaults["enableDemo"] as? Bool, enableDemo else { return nil }
            guard let username = defaults["username"] as? String else { return nil }
            guard let password = defaults["password"] as? String else { return nil }
            guard let host = Secret.appleDemoHost.string else { return nil }
            return MDMLogin(host: host, username: username, password: password)
        }
    }

    private var defaults: [String: Any]? {
        return UserDefaults.standard.dictionary(forKey: rawValue)
    }
}

@objc
public class MDMManager: NSObject {
    @objc
    public static let shared = MDMManager()
    private var token: NSObjectProtocol?

    // Login
    public typealias LoginObserver = (MDMLogin) -> Void
    @objc
    public private(set) var login: MDMLogin?
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
        login = MDMProvider.allCases.compactMap { $0.login }.first
        if let login = login {
            let observers = self.loginObservers
            observers.forEach { $0(login) }
            loginObservers = []
        }
    }
}
