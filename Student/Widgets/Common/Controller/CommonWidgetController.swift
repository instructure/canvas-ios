//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

import Core
import WidgetKit

class CommonWidgetController<Model: WidgetModel> {
    let env = AppEnvironment.shared
    lazy var colors = env.subscribe(GetCustomColors())
    /** Subclasses can store the completion block received from iOS here to invoke it later, when data fetch is ready. */
    var completion: ((Timeline<Model>) -> Void)?

    private let loggedOutModel: Model
    /** We store the last state of the widget and display it in case a refresh is requested when the device is locked and we have no access to the session in keychain. */
    private var cachedModel: Model?
    private let timeout: TimeInterval
    private var isLoggedIn: Bool { LoginSession.mostRecent != nil }
    private var isDeviceUnlocked: Bool {
        guard let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
            return false
        }
        let documentsURL = URL(fileURLWithPath: documentsPath)
        let fileURL = documentsURL.appendingPathComponent("lock-screen-text.txt")
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                _ = try Data(contentsOf: fileURL)
                return true
            } catch {
                return false // read failed, must be locked
            }
        }

        do {
            guard let data = "Lock screen test".data(using: .utf8) else { return true }
            try data.write(to: fileURL, options: .completeFileProtection)
            return true
        } catch {
            return false // default to locked to be safe
        }
    }

    init(loggedOutModel: Model, timeout: TimeInterval) {
        self.loggedOutModel = loggedOutModel
        self.timeout = timeout
    }

    func fetchData() {
        assertionFailure("This method should be overridden in subclasses.")
    }

    final func update() {
        guard isDeviceUnlocked else {
            if let cachedModel = cachedModel {
                updateWidget(model: cachedModel)
            } else {
                updateWidget(model: loggedOutModel)
            }
            return
        }
        guard isLoggedIn else {
            updateWidget(model: loggedOutModel)
            return
        }

        setupLastLoginCredentials()
        fetchData()
    }

    /**
     This method calls the saved `completion` block (if any) with the given `model` and `timeout`. Also sets this property to nil and saves the received `model` to the `cachedModel` property.
     */
    final func updateWidget(model: Model) {
        completion?(Timeline(entries: [model], policy: .after(Date().addingTimeInterval(timeout))))
        self.completion = nil
        cachedModel = model
    }

    private func setupLastLoginCredentials() {
        guard let session = LoginSession.mostRecent else { return }
        env.userDidLogin(session: session)
    }
}
