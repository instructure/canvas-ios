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

#if DEBUG

import Foundation
import UIKit

public class UITestHelpers {
    public enum HelperType: String, Codable {
        case reset, login, show, mockData, mockDownload, tearDown
    }
    public struct Helper: Codable {
        let type: HelperType
        let data: Data?
    }

    static var shared: UITestHelpers?

    public static func setup(_ appDelegate: UIApplicationDelegate) {
        guard ProcessInfo.isUITest else { return }
        shared = UITestHelpers(appDelegate)
    }

    weak var appDelegate: UIApplicationDelegate?
    let decoder = JSONDecoder()
    let keychainBackup = Keychain.entries
    let pasteboardType = "com.instructure.ui-test-helper"
    let window: ActAsUserWindow?

    init(_ appDelegate: UIApplicationDelegate) {
        self.appDelegate = appDelegate
        self.window = appDelegate.window as? ActAsUserWindow

        CacheManager.clear()

        let button = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 1, y: 20, width: 1, height: 1))
        button.accessibilityIdentifier = "ui-test-helper"
        button.accessibilityLabel = "ui-test-helper"
        button.addTarget(self, action: #selector(checkPasteboard), for: .primaryActionTriggered)
        window?.addSubview(button)
        window?.uiTestHelper = button
        window?.layer.speed = 100
        // UIView.setAnimationsEnabled(false)
    }

    @objc func checkPasteboard() {
        guard
            let data = UIPasteboard.general.data(forPasteboardType: pasteboardType),
            let helper = try? decoder.decode(Helper.self, from: data)
        else { return }
        UIPasteboard.general.items.removeAll()
        print("Running UI Test Helper \(helper.type.rawValue)")
        switch helper.type {
        case .reset:
            reset()
        case .login:
            guard let data = helper.data, let params = try? decoder.decode([String].self, from: data) else { return }
            logIn(domain: params[0], token: params[1])
        case .show:
            guard let data = helper.data, let params = try? decoder.decode([String].self, from: data) else { return }
            show(params[0])
        case .mockData:
            guard let data = helper.data else { return }
            MockDistantURLSession.mockData(data)
        case .mockDownload:
            guard let data = helper.data else { return }
            MockDistantURLSession.mockDownload(data)
        case .tearDown:
            tearDown()
        }
    }

    func reset() {
        Keychain.clearEntries()
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

    func logIn(domain: String, token: String) {
        guard let loginDelegate = appDelegate as? LoginDelegate else { return }
        let baseURL = URL(string: "https://\(domain)")!
        loginDelegate.userDidLogin(keychainEntry: KeychainEntry(
            accessToken: token,
            baseURL: baseURL,
            expiresAt: nil,
            locale: "en",
            refreshToken: nil,
            userID: "",
            userName: ""
        ))
    }

    func show(_ route: String) {
        guard let root = window?.rootViewController else { return }
        AppEnvironment.shared.router.route(to: route, from: root, options: [.modal, .embedInNav])
    }

    func tearDown() {
        resetNavigationStack()
        Keychain.clearEntries()
        for entry in keychainBackup {
            Keychain.addEntry(entry)
        }
    }
}

#endif
