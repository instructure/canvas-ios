//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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
import Combine
import WidgetKit

class GradeWidgetProvider: TimelineProvider {
    typealias Entry = GradeWidgetEntry

    private let env = AppEnvironment.shared
    private var refreshDate: Date { Date().addingTimeInterval(.widgetRefresh) }
    private var fetchSubscription: AnyCancellable?

    // MARK: - TimelineProvider Protocol

    func placeholder(in context: TimelineProvider.Context) -> Entry { .publicPreview }

    func getSnapshot(in context: TimelineProvider.Context, completion: @escaping @Sendable (GradeWidgetEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: TimelineProvider.Context, completion: @escaping @Sendable (Timeline<GradeWidgetEntry>) -> Void) {

        if context.isPreview {
            let timeline = Timeline(entries: [placeholder(in: context)], policy: .never)
            completion(timeline)
            return
        }

        guard let session = LoginSession.mostRecent else {
            let refreshDate = Clock.now.addingTimeInterval(.widgetRefresh)
            completion(Timeline(entries: [.loggedOutModel], policy: .after(refreshDate)))
            return
        }

        if fetchSubscription != nil { return }

        setupEnvironment(with: session)
        let getTimeline = fetch()
        let getBrandColors = ReactiveStore(useCase: GetBrandVariables())
            .getEntities()
            .replaceError(with: [])
        fetchSubscription = Publishers.CombineLatest(getTimeline, getBrandColors)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (timeline, brandVars) in
                brandVars.first?.applyBrandTheme()
                completion(timeline)
                self?.fetchSubscription = nil
            }
    }

    // MARK: - Private

    private func setupEnvironment(with session: LoginSession) {
        env.userDidLogin(session: session, isSilent: true)
    }

    private func fetch() -> AnyPublisher<Timeline<GradeWidgetEntry>, Never> {
        // To do
    }
}
