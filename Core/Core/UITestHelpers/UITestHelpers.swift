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

#if DEBUG

import Foundation
import UIKit
import CoreData

public class UITestHelpers {
    public enum Helper: Codable {
        case reset
        case login(LoginSession)
        case show(String)
        case mockData(MockDataMessage)
        case mockDownload(MockDownloadMessage)
        case tearDown
        case currentSession
        case setAnimationsEnabled(Bool)
        case useMocksOnly
        case debug(Any?)

        private enum CodingKeys: String, CodingKey {
            case reset, login, show, mockData, mockDownload, tearDown, currentSession, setAnimationsEnabled, useMocksOnly, debug
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            if container.contains(.reset) {
                self = .reset
            } else if let session = try container.decodeIfPresent(LoginSession.self, forKey: .login) {
                self = .login(session)
            } else if let route = try container.decodeIfPresent(String.self, forKey: .show) {
                self = .show(route)
            } else if let message = try container.decodeIfPresent(MockDataMessage.self, forKey: .mockData) {
                self = .mockData(message)
            } else if let message = try container.decodeIfPresent(MockDownloadMessage.self, forKey: .mockDownload) {
                self = .mockDownload(message)
            } else if container.contains(.tearDown) {
                self = .tearDown
            } else if container.contains(.currentSession) {
                self = .currentSession
            } else if let enabled = try container.decodeIfPresent(Bool.self, forKey: .setAnimationsEnabled) {
                self = .setAnimationsEnabled(enabled)
            } else if container.contains(.useMocksOnly) {
                self = .useMocksOnly
            } else if let data = try container.decodeIfPresent(Data.self, forKey: .debug) {
                self = .debug(try NSKeyedUnarchiver(forReadingFrom: data).decodeObject(forKey: "debug"))
            } else {
                throw DecodingError.typeMismatch(Helper.self, .init(codingPath: container.codingPath, debugDescription: "Couldn't decode \(Helper.self)"))
            }
        }
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case .reset:
                try container.encode(nil as Int?, forKey: .reset)
            case .login(let session):
                try container.encode(session, forKey: .login)
            case .show(let route):
                try container.encode(route, forKey: .show)
            case .mockData(let message):
                try container.encode(message, forKey: .mockData)
            case .mockDownload(let message):
                try container.encode(message, forKey: .mockDownload)
            case .tearDown:
                try container.encode(nil as Int?, forKey: .tearDown)
            case .currentSession:
                try container.encode(nil as Int?, forKey: .currentSession)
            case .setAnimationsEnabled(let enabled):
                try container.encode(enabled, forKey: .setAnimationsEnabled)
            case .useMocksOnly:
                try container.encode(nil as Int?, forKey: .useMocksOnly)
            case .debug(let payload):
                let archiver = NSKeyedArchiver(requiringSecureCoding: false)
                archiver.encode(payload, forKey: "debug")
                try container.encode(archiver.encodedData, forKey: .debug)
            }
        }
    }

    static var shared: UITestHelpers?

    public static func setup(_ appDelegate: UIApplicationDelegate) {
        guard ProcessInfo.isUITest else { return }
        shared = UITestHelpers(appDelegate)
    }

    weak var appDelegate: UIApplicationDelegate?
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()
    let pasteboardType = "com.instructure.ui-test-helper"
    let window: ActAsUserWindow?

    var ipcAppServer: IPCAppServer?
    var ipcDriverClient: IPCClient?

    init(_ appDelegate: UIApplicationDelegate) {
        self.appDelegate = appDelegate
        self.window = appDelegate.window as? ActAsUserWindow

        Keychain.app = Keychain(serviceName: "com.instructure.shared-credentials.tests")
        CacheManager.clear()
        UserDefaults.standard.set(true, forKey: "IS_UI_TEST")
        if let portName = ProcessInfo.processInfo.environment["APP_IPC_PORT_NAME"] {
            ipcAppServer = IPCAppServer(machPortName: portName)
        }
        if let portName = ProcessInfo.processInfo.environment["DRIVER_IPC_PORT_NAME"] {
            ipcDriverClient = IPCClient(serverPortName: portName)
        }
    }

    @discardableResult
    func send(_ message: IPCDriverServerMessage) -> Data? {
        return ipcDriverClient?.requestRemote(message)
    }

    func run(_ helper: Helper) -> Data? {
        print("Running UI Test Helper \(helper)")
        switch helper {
        case .reset:
            reset()
        case .login(let entry):
            logIn(entry)
        case .show(let route):
            show(route)
        case .mockData(let message):
            MockDistantURLSession.mockData(message)
        case .mockDownload(let message):
            MockDistantURLSession.mockDownload(message)
        case .tearDown:
            tearDown()
        case .currentSession:
            return try? encoder.encode(AppEnvironment.shared.currentSession)
        case .setAnimationsEnabled(let enabled):
            setAnimationsEnabled(enabled)
        case .useMocksOnly:
            MockDistantURLSession.setup()
        case .debug:
            // insert ad-hoc debug code here
            ()
        }
        return nil
    }

    func reset() {
        LoginSession.clearAll()
        UserDefaults.standard.removeObject(forKey: MDMManager.MDMUserDefaultsKey)

        guard let loginDelegate = appDelegate as? LoginDelegate, let window = window else { fatalError() }

        // horrible hack to get rid of old modally presented controllers that stick around after the rootViewController is changed
        window.rootViewController = nil
        window.subviews.forEach { $0.removeFromSuperview() }
        window.rootViewController = LoginNavigationController.create(loginDelegate: loginDelegate)

        resetDatabase()
        MockDistantURLSession.reset()
        setAnimationsEnabled(false)
    }

    func resetNavigationStack() {
        guard let root = window?.rootViewController else { return }
        removePresented(root)
        let navController = root as? UINavigationController ?? root.navigationController
        navController?.popToRootViewController(animated: false)
    }

    func removePresented(_ controller: UIViewController) {
        if let presented = controller.presentedViewController {
            removePresented(presented)
            presented.dismiss(animated: false, completion: nil)
        }
    }

    func resetDatabase() {
        try? AppEnvironment.shared.globalDatabase.clearAllRecords()
        try? AppEnvironment.shared.database.clearAllRecords()
        try? NSPersistentContainer.shared.clearAllRecords()
    }

    func logIn(_ entry: LoginSession) {
        guard let loginDelegate = appDelegate as? LoginDelegate else { fatalError() }
        loginDelegate.userDidLogin(session: entry)
    }

    func show(_ route: String) {
        guard let root = window?.rootViewController else { return }
        AppEnvironment.shared.router.route(to: route, from: root, options: [.modal, .embedInNav])
    }

    func tearDown() {
        resetNavigationStack()
        LoginSession.clearAll()
    }

    func setAnimationsEnabled(_ enabled: Bool) {
        window?.layer.speed = enabled ? 1 : 100
        UIView.setAnimationsEnabled(enabled)
    }
}

#endif
