//
// Copyright (C) 2019-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#if DEBUG

import Core
import Foundation
import UIKit

class UITestHelpers {
    static var shared = UITestHelpers()

    static func setup() {
        guard ProcessInfo.isUITest else { return }
        _ = shared
    }

    let decoder = JSONDecoder()
    let pasteboardType = "com.instructure.ui-test-helper"

    init() {
        CacheManager.clear()

        guard let window = appDelegate.window as? ActAsUserWindow else { return }
        let button = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 1, y: 20, width: 1, height: 1))
        button.accessibilityIdentifier = "ui-test-helper"
        button.accessibilityLabel = "ui-test-helper"
        button.addTarget(self, action: #selector(checkPasteboard), for: .primaryActionTriggered)
        window.addSubview(button)
        window.uiTestHelper = button
    }

    @objc func checkPasteboard() {
        guard
            let data = UIPasteboard.general.data(forPasteboardType: pasteboardType),
            let helper = try? decoder.decode(UITestHelper.self, from: data)
        else { return }
        UIPasteboard.general.items.removeAll()
        print("Running UI Test Helper \(helper.type.rawValue)")
        switch helper.type {
        case .reset:
            reset()
        case .login:
            guard let data = helper.params, let params = try? decoder.decode([String].self, from: data) else { return }
            logIn(domain: params[0], token: params[1])
        case .show:
            guard let data = helper.params, let params = try? decoder.decode([String].self, from: data) else { return }
            show(params[0])
        case .mockData:
            guard let data = helper.params else { return }
            MockDistantURLSession.mockData(data)
        case .mockDownload:
            guard let data = helper.params else { return }
            MockDistantURLSession.mockDownload(data)
        }
    }

    // swiftlint:disable:next force_cast weak_delegate
    var appDelegate = UIApplication.shared.delegate as! AppDelegate

    func reset() {
        appDelegate.window!.layer.speed = 100
        resetNavigationStack()
        resetDatabase()
        MockDistantURLSession.reset()
    }

    private func resetNavigationStack() {
        guard let root = appDelegate.window?.rootViewController else { return }
        removePresented(root)
        let navController = root as? UINavigationController ?? root.navigationController
        navController?.popToRootViewController(animated: false)
    }

    private func removePresented(_ controller: UIViewController) {
        if let presented = controller.presentedViewController {
            removePresented(presented)
            presented.dismiss(animated: false, completion: nil)
        }
    }

    private func resetDatabase() {
        try? AppEnvironment.shared.globalDatabase.clearAllRecords()
        try? AppEnvironment.shared.database.clearAllRecords()
    }

    func logIn(domain: String, token: String) {
        let baseURL = URL(string: "https://\(domain)")!
        appDelegate.setup(session: KeychainEntry(accessToken: token, baseURL: baseURL, expiresAt: nil, locale: "en", refreshToken: nil, userID: "", userName: ""))
    }

    func show(_ route: String) {
        guard var controller = router.match(.parse(route)) else {
            fatalError("No route for \(route)")
        }
        if !(controller is UINavigationController) {
            controller = UINavigationController(rootViewController: controller)
        }
        appDelegate.window!.rootViewController = controller
        controller.loadViewIfNeeded()
    }
}

// Needs to match codable serialization from UI test target
enum UITestHelperType: String, Codable {
    case reset, login, show, mockData, mockDownload
}
struct UITestHelper: Codable {
    let type: UITestHelperType
    let params: Data?
}

#endif
