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

public class UITestHelpers {
    public enum Helper: Codable {
        case reset
        case login(LoginSession)
        case show(String)
        case mockData(MockDataMessage)
        case mockDownload(MockDownloadMessage)
        case tearDown

        private enum Tag: String, Codable {
            case reset, login, show, mockData, mockDownload, tearDown
        }
        private enum CodingKeys: String, CodingKey { case tag, param }
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            switch try container.decode(Tag.self, forKey: .tag) {
            case .reset:
                self = .reset
            case .login:
                self = .login(try container.decode(LoginSession.self, forKey: .param))
            case .show:
                self = .show(try container.decode(String.self, forKey: .param))
            case .mockData:
                self = .mockData(try container.decode(MockDataMessage.self, forKey: .param))
            case .mockDownload:
                self = .mockDownload(try container.decode(MockDownloadMessage.self, forKey: .param))
            case .tearDown:
                self = .tearDown
            }
        }
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case .reset:
                try container.encode(Tag.reset, forKey: .tag)
            case .login(let session):
                try container.encode(Tag.login, forKey: .tag)
                try container.encode(session, forKey: .param)
            case .show(let route):
                try container.encode(Tag.show, forKey: .tag)
                try container.encode(route, forKey: .param)
            case .mockData(let message):
                try container.encode(Tag.mockData, forKey: .tag)
                try container.encode(message, forKey: .param)
            case .mockDownload(let message):
                try container.encode(Tag.mockDownload, forKey: .tag)
                try container.encode(message, forKey: .param)
            case .tearDown:
                try container.encode(Tag.tearDown, forKey: .tag)
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

    init(_ appDelegate: UIApplicationDelegate) {
        self.appDelegate = appDelegate
        self.window = appDelegate.window as? ActAsUserWindow

        LoginSession.keychain = Keychain(serviceName: "com.instructure.shared-credentials.tests")
        CacheManager.clear()
        UserDefaults.standard.set(true, forKey: "IS_UI_TEST")
        ExperimentalFeature.allEnabled = true

        let button = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 1, y: 44, width: 1, height: 1))
        button.accessibilityIdentifier = "ui-test-helper"
        button.accessibilityLabel = "ui-test-helper"
        button.addTarget(self, action: #selector(checkPasteboard), for: .primaryActionTriggered)
        window?.addSubview(button)
        window?.uiTestHelper = button
        window?.layer.speed = 100
        UIView.setAnimationsEnabled(false)
    }

    @objc func checkPasteboard() {
        guard
            let data = UIPasteboard.general.data(forPasteboardType: pasteboardType),
            let helper = try? decoder.decode(Helper.self, from: data)
        else { return }
        UIPasteboard.general.items.removeAll()
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
        }
    }

    func reset() {
        LoginSession.clearAll()
        UserDefaults.standard.removeObject(forKey: MDMManager.MDMUserDefaultsKey)
        (appDelegate as? LoginDelegate)?.changeUser()
        resetDatabase()
        MockDistantURLSession.reset()
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
    }

    func logIn(_ entry: LoginSession) {
        guard let loginDelegate = appDelegate as? LoginDelegate else { return }
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
}

#endif
