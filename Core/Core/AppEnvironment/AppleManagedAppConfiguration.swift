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

/// Manages Apple MDM Configuration
///
/// You can test this locally with command line arguments
// -com.apple.configuration.managed '<dict><key>enableDemo</key><true/><key>username</key><string>username</string><key>password</key><string>password</string></dict>'
/// `username` and `password` values should match what's set in App Store Connect.
public class AppleManagedAppConfiguration {
    public struct Demo {
        public let host: String
        public let username: String
        public let password: String

        fileprivate init?(defaults: UserDefaults) {
            guard
                let config = defaults.dictionary(forKey: "com.apple.configuration.managed"),
                let enableDemo = config["enableDemo"] as? Bool,
                enableDemo,
                let username = config["username"] as? String,
                let password = config["password"] as? String
            else {
                return nil
            }
            self.username = username
            self.password = password
            self.host = "pcraighill.instructure.com"
        }
    }

    public typealias DemoObserver = (Demo) -> Void

    public static let shared = AppleManagedAppConfiguration()

    public private(set) var demo: Demo?

    private var token: NSObjectProtocol?
    private var demoObservers: [DemoObserver] = []

    init() {
        token = NotificationCenter.default.addObserver(forName: UserDefaults.didChangeNotification, object: nil, queue: .main) { [weak self] _ in
            self?.update()
        }
    }

    deinit {
        if let token = token {
            NotificationCenter.default.removeObserver(token)
        }
    }

    /// Get host, username, and password once demo becomes enabled.
    ///
    /// `callback` will only be called once.
    public func onDemoEnabled(callback: @escaping DemoObserver) {
        if let demo = demo {
            callback(demo)
            return
        }
        demoObservers.append(callback)
    }

    private func update() {
        if let demo = Demo(defaults: .standard) {
            self.demo = demo
            let observers = demoObservers
            observers.forEach { $0(demo) }
            demoObservers = []
        }
    }
}
