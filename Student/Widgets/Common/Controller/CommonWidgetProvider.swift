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
    /** This is the completion block received from iOS. Invoked from `updateWidget(model:)`, when data fetch is ready.
     After one invocation this property is set to nil because subsequent invocations on the same completion handler causes a crash in WidgetKit. */
    private var completion: ((Timeline<Model>) -> Void)?
    private let timeout: TimeInterval
    private var isLoggedIn: Bool { LoginSession.mostRecent != nil }

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
        completion?(Timeline(entries: [model], policy: .after(Date().addingTimeInterval(timeout))))
        self.completion = nil
    }

    // MARK: - Private Methods

    private func update() {
        guard isLoggedIn else {
            updateWidget(model: loggedOutModel)
            return
        }

        setupLastLoginCredentials()
        fetchData()
    }

    private func setupLastLoginCredentials() {
        guard let session = LoginSession.mostRecent else { return }
        env.userDidLogin(session: session, isSilent: true)
    }
}

extension CommonWidgetProvider: TimelineProvider {
    typealias Entry = Model

    func placeholder(in context: TimelineProvider.Context) -> Entry {
        // swiftlint:disable:next force_cast
        Model.publicPreview as! Model
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
