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
        case reset(useMocks: Bool)
        case login(LoginSession)
        case show(String, RouteOptions)
        case mockNow(Date)
        case tearDown
        case currentSession
        case setAnimationsEnabled(Bool)
        case debug(Any?)
        case enableExperimentalFeatures([ExperimentalFeature])
        case showKeyboard

        private enum CodingKeys: String, CodingKey {
            case reset, login, show, options, tearDown, currentSession, setAnimationsEnabled, debug, mockNow, experimentalFeatures, showKeyboard
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            if let useMocks = try container.decodeIfPresent(Bool.self, forKey: .reset) {
                self = .reset(useMocks: useMocks)
            } else if let session = try container.decodeIfPresent(LoginSession.self, forKey: .login) {
                self = .login(session)
            } else if let route = try container.decodeIfPresent(String.self, forKey: .show) {
                self = .show(route, try container.decode(RouteOptions.self, forKey: .options))
            } else if container.contains(.tearDown) {
                self = .tearDown
            } else if container.contains(.currentSession) {
                self = .currentSession
            } else if let enabled = try container.decodeIfPresent(Bool.self, forKey: .setAnimationsEnabled) {
                self = .setAnimationsEnabled(enabled)
            } else if let data = try container.decodeIfPresent(Data.self, forKey: .debug) {
                self = .debug(try NSKeyedUnarchiver(forReadingFrom: data).decodeObject(forKey: "debug"))
            } else if let date = try container.decodeIfPresent(Date.self, forKey: .mockNow) {
                self = .mockNow(date)
            } else if let features = try container.decodeIfPresent([ExperimentalFeature].self, forKey: .experimentalFeatures) {
                self = .enableExperimentalFeatures(features)
            } else if container.contains(.showKeyboard) {
                self = .showKeyboard
            } else {
                throw DecodingError.typeMismatch(Helper.self, .init(codingPath: container.codingPath, debugDescription: "Couldn't decode \(Helper.self)"))
            }
        }
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case .reset(let useMocks):
                try container.encode(useMocks, forKey: .reset)
            case .login(let session):
                try container.encode(session, forKey: .login)
            case .show(let route, let options):
                try container.encode(route, forKey: .show)
                try container.encode(options, forKey: .options)
            case .tearDown:
                try container.encode(nil as Int?, forKey: .tearDown)
            case .currentSession:
                try container.encode(nil as Int?, forKey: .currentSession)
            case .setAnimationsEnabled(let enabled):
                try container.encode(enabled, forKey: .setAnimationsEnabled)
            case .debug(let payload):
                let archiver = NSKeyedArchiver(requiringSecureCoding: false)
                archiver.encode(payload, forKey: "debug")
                try container.encode(archiver.encodedData, forKey: .debug)
            case .mockNow(let date):
                try container.encode(date, forKey: .mockNow)
            case .enableExperimentalFeatures(let features):
                try container.encode(features, forKey: .experimentalFeatures)
            case .showKeyboard:
                try container.encode(nil as Int?, forKey: .showKeyboard)
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

        CacheManager.clear()
        UserDefaults.standard.set(true, forKey: "IS_UI_TEST")
        if let portName = ProcessInfo.processInfo.environment["APP_IPC_PORT_NAME"] {
            ipcAppServer = IPCAppServer(machPortName: portName)
        }
        if let portName = ProcessInfo.processInfo.environment["DRIVER_IPC_PORT_NAME"] {
            ipcDriverClient = IPCClient(serverPortName: portName)
        }
    }

    private let ipcQueue = DispatchQueue(label: "UITestHelper-ipc")
    private let callbackQueue = DispatchQueue(label: "UITestHelper-callback")
    func send(_ message: IPCDriverServerMessage, callback: ((Data?) -> Void)? = nil) {
        ipcQueue.async {
            let result = try? self.ipcDriverClient?.requestRemote(message)
            self.callbackQueue.async { callback?(result) }
        }
    }

    func run(_ helper: Helper) -> Data? {
        print("Running UI Test Helper \(helper)")
        switch helper {
        case .reset(let useMocks):
            reset(useMocks: useMocks)
        case .login(let entry):
            logIn(entry)
        case .show(let route, let options):
            show(route, options: options)
        case .tearDown:
            tearDown()
        case .currentSession:
            return try? encoder.encode(AppEnvironment.shared.currentSession)
        case .setAnimationsEnabled(let enabled):
            setAnimationsEnabled(enabled)
        case .debug:
            // insert ad-hoc debug code here
            ()
        case .mockNow(let date):
            Clock.mockNow(date)
        case .enableExperimentalFeatures(let features):
            ExperimentalFeature.allEnabled = false
            features.forEach { $0.isEnabled = true }
        case .showKeyboard:
            showKeyboard()
        }
        return nil
    }

    func reset(useMocks: Bool) {
        LoginSession.clearAll()
        UserDefaults.standard.removeObject(forKey: MDMManager.MDMUserDefaultsKey)

        guard let loginDelegate = appDelegate as? LoginDelegate, let window = window else { fatalError() }
        if useMocks, let session = AppEnvironment.shared.currentSession {
            // caching is ok for a real session, but bad for a mocked one
            loginDelegate.userDidLogout(session: session)
        }

        // horrible hack to get rid of old modally presented controllers that stick around after the rootViewController is changed
        window.rootViewController = nil
        window.subviews.forEach { $0.removeFromSuperview() }
        var app: App = .student
        if Bundle.main.isParentApp {
            app = .parent
        }
        if Bundle.main.isTeacherApp {
            app = .teacher
        }
        window.rootViewController = LoginNavigationController.create(loginDelegate: loginDelegate, app: app)

        resetDatabase()
        API.resetMocks(useMocks: useMocks)
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
        resetDatabase()
    }

    func show(_ route: String, options: RouteOptions) {
        guard let root = window?.rootViewController else { return }
        AppEnvironment.shared.router.route(to: route, from: root, options: options)
    }

    func tearDown() {
        resetNavigationStack()
        LoginSession.clearAll()
    }

    func setAnimationsEnabled(_ enabled: Bool) {
        window?.layer.speed = enabled ? 1 : 100
        UIView.setAnimationsEnabled(enabled)
    }

    func showKeyboard() {
        let shared = NSClassFromString("UIKeyboardImpl")!.value(forKey: "sharedInstance") as AnyObject
        shared.perform(#selector(UIKeyboardImplLike.showKeyboard), with: nil, afterDelay: 0)
    }
}

@objc protocol UIKeyboardImplLike {
    @objc func showKeyboard()
}

#endif
