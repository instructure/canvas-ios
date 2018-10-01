//
// Copyright (C) 2018-present Instructure, Inc.
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

import Foundation
import UIKit
import Core
@testable import Student

// https://github.com/google/EarlGrey/blob/earlgrey2/docs/swift-white-boxing.md

@objc
protocol TestHost {
    func reset()
    func logIn(domain: String, token: String)
    func show(_ route: String)
}

extension GREYHostApplicationDistantObject: TestHost {
    var appDelegate: AppDelegate {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("wrong app delegate type")
        }
        return delegate
    }

    func reset() {
        resetNavigationStack()
        resetDatabase()
    }

    private func resetNavigationStack() {
        let window = UIApplication.shared.delegate!.window!!
        let navController = window.rootViewController as? UINavigationController ?? window.rootViewController?.navigationController
        navController?.popToRootViewController(animated: false)
    }

    private func resetDatabase() {
        do {
            let store = appDelegate.environment.database
            try store.clearAllRecords()
        } catch {
            fatalError("failed to reset database")
        }
    }

    func logIn(domain: String, token: String) {
        let baseURL = "https://\(domain)"
        Keychain.currentSession = KeychainEntry(token: token, baseURL: baseURL)
    }

    func show(_ route: String) {
        guard let controller = router.match(.parse(route)) else {
            fatalError("No route for \(route)")
        }
        let nav = UINavigationController(rootViewController: controller)
        UIApplication.shared.delegate!.window!!.rootViewController = nav
    }
}
