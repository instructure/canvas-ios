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

class CommonWidgetProvider<Model: WidgetModel> {
    let env = AppEnvironment.shared

    /** The model to present in case the user is logged out from the app and there's no session we could use to fetch data. */
    private let loggedOutModel: Model
    /** We store the last state of the widget and display it in case a refresh is requested when the device is locked and we have no access to the session in keychain. */
    private var cachedModel: Model?
    /** This is the completion block received from iOS. Invoked from `updateWidget(model:)`, when data fetch is ready.
     After one invocation this property is set to nil because subsequent invocations on the same completion handler causes a crash in WidgetKit. */
    private var completion: ((Timeline<Model>) -> Void)?
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

    // MARK: - Public Interface

    init(loggedOutModel: Model, timeout: TimeInterval) {
        self.loggedOutModel = loggedOutModel
        self.timeout = timeout
    }

    func fetchData() {
        assertionFailure("This method should be overridden in subclasses.")
    }

    /**
     This method should be called at the end of the `fetchData()`method when data is ready. 
     This method calls the saved `completion` block (if any) with the given `model` and `timeout`.
     Also sets this property to nil and saves the received `model` to the `cachedModel` property.
     */
    final func updateWidget(model: Model) {
        Logger.shared.log()
        completion?(Timeline(entries: [model], policy: .after(Date().addingTimeInterval(timeout))))
        self.completion = nil
        cachedModel = model
    }

    // MARK: - Private Methods

    private func update() {
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

    private func setupLastLoginCredentials() {
        guard let session = LoginSession.mostRecent else { return }
        env.userDidLogin(session: session)
    }
}

extension CommonWidgetProvider: TimelineProvider {
    typealias Entry = Model

    func placeholder(in context: TimelineProvider.Context) -> Entry {
        // swiftlint:disable:next force_cast
        return Model.publicPreview as! Model
    }

    func getSnapshot(in context: TimelineProvider.Context, completion: @escaping (Entry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: TimelineProvider.Context, completion: @escaping (Timeline<Entry>) -> Void) {
        if context.isPreview {
            completion(Timeline(entries: [placeholder(in: context)], policy: .after(Date())))
            return
        }

        self.completion = completion
        update()
    }
}
